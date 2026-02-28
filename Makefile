CC      = gcc
CFLAGS  = -O3 -Wall
PREFIX  = /usr
BINDIR  = $(PREFIX)/bin

all: guhshot

config.h:
	cp config.def.h config.h 2>/dev/null || echo '/* Add defaults here */' > config.h

guhshot: guhshot.c config.h
	$(CC) $(CFLAGS) guhshot.c -o guhshot

install: guhshot
	install -Dm755 guhshot $(DESTDIR)$(BINDIR)/guhshot

clean:
	rm -f guhshot

.PHONY: all install clean