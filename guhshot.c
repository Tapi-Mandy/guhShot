#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <time.h>
#include <sys/stat.h>
#include <wordexp.h>
#include "config.h"

typedef struct {
    int save;
    int copy;
    int swappy;
    int mode; // -1: none, 0: full, 1: region, 2: monitor
} Opts;

void usage(char *name) {
    printf("Usage: %s [ACTION] [MODIFIERS]\n\n", name);
    printf("Actions:\n");
    printf("  -f, --full           Capture all monitors (Default for single monitor setups)\n");
    printf("  -m, --monitor        Capture the focused monitor (For multi-monitor setups)\n");
    printf("  -r, --region         Select a region to capture\n\n");
    printf("Modifiers:\n");
    printf("  -S, --enable-save    Save to disk\n");
    printf("  -s, --disable-save   Disable saving to disk\n");
    printf("  -C, --enable-copy    Copy to clipboard\n");
    printf("  -c, --disable-copy   Disable copying to clipboard\n");
    printf("  -e, --swappy         Edit with swappy before saving\n\n");
    printf("Note: Settings are persistent. Use modifiers to change default behavior.\n");
    exit(1);
}

void notify(Opts *o) {
    char cmd[512], msg[128];
    if (o->save && o->copy) sprintf(msg, "Saved & Copied!");
    else if (o->copy)       sprintf(msg, "Copied to Clipboard!");
    else if (o->save)       sprintf(msg, "Screenshot Saved!");
    else return;

    sprintf(cmd, "notify-send '%s' '%s' -a '%s' -i %s", 
            notif_title, msg, notif_title, notif_icon);
    system(cmd);
}

char* expand_path(const char* path) {
    wordexp_t p;
    char* res;
    if (wordexp(path, &p, 0) != 0) return strdup(path);
    res = strdup(p.we_wordv[0]);
    wordfree(&p);
    return res;
}

void take_shot(Opts *o) {
    char ts[64], tmp[512], fin[512], cmd[2048], target[256] = "";
    time_t t = time(NULL);
    strftime(ts, sizeof(ts), "%Y-%m-%d_%H-%M-%S", localtime(&t));
    
    char *real_dir = expand_path(screenshot_dir);
    sprintf(tmp, "/tmp/guh_%s.png", ts);
    sprintf(fin, "%s/guhShot_%s.png", real_dir, ts);

    if (o->mode == 2) { /* Monitor mode: Detect focused output */
        FILE *fp = popen("slurp -p -f '%o'", "r");
        if (fp) {
            char out[64];
            if (fgets(out, sizeof(out), fp)) {
                out[strcspn(out, "\n")] = 0;
                sprintf(target, "-o %s", out);
            }
            pclose(fp);
        }
    } else if (o->mode == 1) { /* Region mode */
        sprintf(target, "-g \"$(slurp)\"");
    } 
    /* mode 0 (Full) remains empty target for grim default */

    sprintf(cmd, "grim %s %s", target, tmp);
    if (system(cmd) != 0) {
        free(real_dir);
        return;
    }

    if (o->swappy) {
        sprintf(cmd, "swappy -f %s -o %s", tmp, tmp);
        system(cmd);
    }
    if (o->copy) {
        sprintf(cmd, "wl-copy -t image/png < %s", tmp);
        system(cmd);
    }
    if (o->save) {
        sprintf(cmd, "mkdir -p %s && cp %s %s", real_dir, tmp, fin);
        system(cmd);
    }

    notify(o);
    remove(tmp);
    free(real_dir);
}

void get_state_path(char *path) {
    char *xdg = getenv("XDG_CACHE_HOME");
    if (xdg) sprintf(path, "%s/guhshot", xdg);
    else sprintf(path, "%s/.cache/guhshot", getenv("HOME"));
    mkdir(path, 0755);
    strcat(path, "/state");
}

void load_state(Opts *o) {
    char path[512]; get_state_path(path);
    FILE *f = fopen(path, "r");
    if (f) {
        fscanf(f, "save=%d\ncopy=%d", &o->save, &o->copy);
        fclose(f);
    }
}

void save_state(Opts *o) {
    char path[512]; get_state_path(path);
    FILE *f = fopen(path, "w");
    if (f) {
        fprintf(f, "save=%d\ncopy=%d", o->save, o->copy);
        fclose(f);
    }
}

int main(int argc, char **argv) {
    // Start with config.h defaults, then override with last saved state
    Opts o = {default_save, default_copy, 0, -1};
    load_state(&o);

    static struct option long_opts[] = {
        {"full",         no_argument, 0, 'f'},
        {"monitor",      no_argument, 0, 'm'},
        {"region",       no_argument, 0, 'r'},
        {"enable-save",  no_argument, 0, 'S'},
        {"disable-save", no_argument, 0, 's'},
        {"enable-copy",  no_argument, 0, 'C'},
        {"disable-copy", no_argument, 0, 'c'},
        {"swappy",       no_argument, 0, 'e'},
        {0, 0, 0, 0}
    };

    int opt, state_changed = 0;
    while ((opt = getopt_long(argc, argv, "fmrSsCce", long_opts, NULL)) != -1) {
        switch (opt) {
            case 'f': o.mode = 0; break;
            case 'm': o.mode = 2; break;
            case 'r': o.mode = 1; break;
            case 'S': o.save = 1; state_changed = 1; break;
            case 's': o.save = 0; state_changed = 1; break;
            case 'C': o.copy = 1; state_changed = 1; break;
            case 'c': o.copy = 0; state_changed = 1; break;
            case 'e': o.swappy = 1; break;
            default:  usage(argv[0]);
        }
    }

    // If you used a flag like -s or -C, save that choice
    if (state_changed) {
        save_state(&o);
        printf("  Save to disk:      %s\n", o.save ? "ENABLED" : "DISABLED");
        printf("  Copy to clipboard: %s\n", o.copy ? "ENABLED" : "DISABLED");
        
        // If we ONLY changed a setting and didn't provide an action (-f, -m, -r),
        // exit cleanly here so the user knows it worked without seeing the help menu.
        if (o.mode == -1) return 0;
    }

    // If no action was provided (and no settings were changed), show help
    if (o.mode == -1) usage(argv[0]);

    take_shot(&o);
    return 0;
}