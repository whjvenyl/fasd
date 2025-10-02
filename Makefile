PREFIX?= /usr/local
BINDIR?= ${PREFIX}/bin
INSTALL?= install
INSTALLDIR= ${INSTALL} -d
INSTALLBIN= ${INSTALL} -p -m 755

all:

uninstall:
	rm -f ${DESTDIR}${BINDIR}/fasd

install:
	${INSTALLDIR} ${DESTDIR}${BINDIR}
	${INSTALLBIN} fasd ${DESTDIR}${BINDIR}

.PHONY: all install uninstall
