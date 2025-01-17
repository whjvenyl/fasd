PREFIX?= /usr/local
BINDIR?= ${PREFIX}/bin
MANDIR?= ${PREFIX}/share/man
INSTALL?= install
INSTALLDIR= ${INSTALL} -d
INSTALLBIN= ${INSTALL} -p -m 755

all:

uninstall:
	rm -f ${DESTDIR}${BINDIR}/fasd
	rm -f ${DESTDIR}${MANDIR}/man1/fasd.1

install:
	${INSTALLDIR} ${DESTDIR}${BINDIR}
	${INSTALLBIN} fasd ${DESTDIR}${BINDIR}

.PHONY: all install uninstall
