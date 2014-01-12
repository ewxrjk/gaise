#
# This file is part of Gaise
# Copyright © 2011 Richard Kettlewell
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
#
prefix=/usr/local
bindir=${prefix}/bin
libdir=${prefix}/lib
mandir=${prefix}/man
man1dir=${mandir}/man1
pkglibdir=${libdir}/gaise
INSTALL=install -c

include defs.$(shell uname -s)

VERSION=0.2+

all: ${MODULE} noipv6 noipv4 gaisetest

noipv6: gaise.m4 Makefile
	m4 -D__pkglibdir__="${pkglibdir}" \
		-DVERSION="${VERSION}" \
		-D__module__=${MODULE} \
		-D__variable__=${VARIABLE} \
		-D__command__=noipv6 \
		-D__suppress__=IPV6 \
		$< > $@.tmp
	mv $@.tmp $@
	chmod 755 $@

noipv4: gaise.m4 Makefile
	m4 -D__pkglibdir__="${pkglibdir}" \
		-DVERSION="${VERSION}" \
		-D__module__=${MODULE} \
		-D__variable__=${VARIABLE} \
		-D__command__=noipv4 \
		-D__suppress__=IPV4 \
		$< > $@.tmp
	mv $@.tmp $@
	chmod 755 $@

$(MODULE): gaise.lo
	$(CC) $(CFLAGS) $(SHAREFLAGS) -o $@ $^ $(LIBS)

gaisetest: gaisetest.o
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

install: installdirs
	$(INSTALL) -m 755 noipv6 $(bindir)/noipv6
	$(INSTALL) -m 755 noipv4 $(bindir)/noipv4
	$(INSTALL) -m 644 ${MODULE} $(libdir)/gaise/${MODULE} 
	$(INSTALL) -m 644 noipv6.1 $(man1dir)/noipv6.1
	$(INSTALL) -m 644 noipv4.1 $(man1dir)/noipv4.1

install-strip: install

uninstall:
	rm -f $(bindir)/noipv6
	rm -f $(bindir)/noipv4
	rm -f $(libdir)/gaise/${MODULE}
	rm -f $(man1dir)/noipv6.1
	rm -f $(man1dir)/noipv4.1
	-rmdir $(libdir)/gaise

installdirs:
	mkdir -p $(libdir)
	mkdir -p $(libdir)/gaise
	mkdir -p $(bindir)
	mkdir -p $(man1dir)

clean:
	rm -f *.so
	rm -f *.lo
	rm -f *.dylib
	rm -f noipv6
	rm -f noipv4
	rm -f gaisetest

distclean: clean

check: check-0 check-4 check-6

check-0: gaisetest
	./gaisetest

check-4: gaisetest noipv4 ${MODULE}
	GAISE_PATH=. ./noipv4 ./gaisetest 4

check-6: gaisetest noipv6 ${MODULE}
	GAISE_PATH=. ./noipv6 ./gaisetest 6

dist:
	rm -rf gaise-${VERSION}
	mkdir gaise-${VERSION}
	cp COPYING Makefile README *.c gaise-${VERSION} 
	cp gaise.m4 noipv6.1 gaise-${VERSION} 
	cp noipv4.1 gaise-${VERSION} 
	cp defs.Linux gaise-${VERSION}
	mkdir gaise-${VERSION}/debian
	cp debian/changelog gaise-${VERSION}/debian
	cp debian/control debian/copyright gaise-${VERSION}/debian
	cp debian/rules gaise-${VERSION}/debian
	chmod +x gaise-${VERSION}/debian/rules
	tar cf gaise-${VERSION}.tar gaise-${VERSION}
	gzip -9vf gaise-${VERSION}.tar
	rm -rf gaise-${VERSION}

distcheck: dist
	tar xfz gaise-${VERSION}.tar.gz
	cd gaise-${VERSION} && make check
	cd gaise-${VERSION} && make install prefix=distcheck/usr/local
	rm -rf gaise-${VERSION}

%.lo : %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -fpic -c $< -o $@

echo-version:
	@echo "$(VERSION)"
