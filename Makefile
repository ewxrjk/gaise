#
# This file is part of Gaise
# Copyright © 2011, 2016 Richard Kettlewell
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
PACKAGE_NAME = gaise
PACKAGE_VERSION = 0.3

prefix=/usr/local
bindir=${prefix}/bin
libdir=${prefix}/lib
mandir=${prefix}/man
man1dir=${mandir}/man1
pkglibdir=${libdir}/${PACKAGE_NAME}
INSTALL=install -c

include defs.$(shell uname -s)

all: ${MODULE} noipv6 noipv4 gaisetest

noipv6: gaise.m4 Makefile
	m4 -D__pkglibdir__="${pkglibdir}" \
		-DVERSION="${PACKAGE_VERSION}" \
		-D__module__=${MODULE} \
		-D__variable__=${VARIABLE} \
		-D__command__=noipv6 \
		-D__suppress__=IPV6 \
		$< > $@.tmp
	mv $@.tmp $@
	chmod 755 $@

noipv4: gaise.m4 Makefile
	m4 -D__pkglibdir__="${pkglibdir}" \
		-DVERSION="${PACKAGE_VERSION}" \
		-D__module__=${MODULE} \
		-D__variable__=${VARIABLE} \
		-D__command__=noipv4 \
		-D__suppress__=IPV4 \
		$< > $@.tmp
	mv $@.tmp $@
	chmod 755 $@

$(MODULE): gaise.lo
	$(CC) $(CFLAGS) $(LDFLAGS) $(SHAREFLAGS) -o $@ $^ $(LIBS)

gaisetest: gaisetest.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

install: installdirs
	$(INSTALL) -m 755 noipv6 $(bindir)/noipv6
	$(INSTALL) -m 755 noipv4 $(bindir)/noipv4
	$(INSTALL) -m 644 ${MODULE} $(pkglibdir)/${MODULE}
	$(INSTALL) -m 644 noipv6.1 $(man1dir)/noipv6.1
	$(INSTALL) -m 644 noipv4.1 $(man1dir)/noipv4.1

install-strip: install

uninstall:
	rm -f $(bindir)/noipv6
	rm -f $(bindir)/noipv4
	rm -f $(pkglibdir)/${MODULE}
	rm -f $(man1dir)/noipv6.1
	rm -f $(man1dir)/noipv4.1
	-rmdir $(pkglibdir)

installdirs:
	mkdir -p $(pkglibdir)
	mkdir -p $(bindir)
	mkdir -p $(man1dir)

clean:
	rm -f *.so
	rm -f *.lo
	rm -f *.o
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
	rm -rf $(PACKAGE_NAME)-${PACKAGE_VERSION}
	mkdir $(PACKAGE_NAME)-${PACKAGE_VERSION}
	cp COPYING Makefile README *.c $(PACKAGE_NAME)-${PACKAGE_VERSION}
	cp $(PACKAGE_NAME).m4 noipv6.1 $(PACKAGE_NAME)-${PACKAGE_VERSION}
	cp noipv4.1 $(PACKAGE_NAME)-${PACKAGE_VERSION}
	cp defs.Linux $(PACKAGE_NAME)-${PACKAGE_VERSION}
	cp defs.GNU $(PACKAGE_NAME)-${PACKAGE_VERSION}
	mkdir $(PACKAGE_NAME)-${PACKAGE_VERSION}/debian
	cp debian/changelog $(PACKAGE_NAME)-${PACKAGE_VERSION}/debian
	cp debian/control debian/copyright $(PACKAGE_NAME)-${PACKAGE_VERSION}/debian
	cp debian/rules $(PACKAGE_NAME)-${PACKAGE_VERSION}/debian
	chmod +x $(PACKAGE_NAME)-${PACKAGE_VERSION}/debian/rules
	tar cf $(PACKAGE_NAME)-${PACKAGE_VERSION}.tar $(PACKAGE_NAME)-${PACKAGE_VERSION}
	gzip -9vf $(PACKAGE_NAME)-${PACKAGE_VERSION}.tar
	rm -rf $(PACKAGE_NAME)-${PACKAGE_VERSION}

distcheck: dist
	tar xfz $(PACKAGE_NAME)-${PACKAGE_VERSION}.tar.gz
	cd $(PACKAGE_NAME)-${PACKAGE_VERSION} && make check
	cd $(PACKAGE_NAME)-${PACKAGE_VERSION} && make install prefix=distcheck/usr/local
	rm -rf $(PACKAGE_NAME)-${PACKAGE_VERSION}

%.lo : %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -fpic -c $< -o $@

echo-version:
	@echo "$(PACKAGE_VERSION)"
