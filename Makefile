prefix=/usr/local
bindir=${prefix}/bin
libdir=${prefix}/lib
mandir=${prefix}/man
man1dir=${mandir}/man1
pkglibdir=${libdir}/gaise
INSTALL=install -c

include defs.$(shell uname -s)

VERSION=0.1

all: ${MODULE} noipv6

noipv6: noipv6.m4 Makefile
	m4 -Dpkglibdir="${pkglibdir}" \
		-DVERSION="${VERSION}" \
		-D__module__=${MODULE} \
		-D__variable__=${VARIABLE} \
		noipv6.m4 > noipv6.tmp
	mv noipv6.tmp noipv6
	chmod 755 noipv6

$(MODULE): gaise.lo
	$(CC) $(CFLAGS) $(SHAREFLAGS) -o $@ $^ $(LIBS)

install: installdirs
	$(INSTALL) -m 755 noipv6 $(bindir)/noipv6
	$(INSTALL) -m 644 ${MODULE} $(libdir)/gaise/${MODULE} 
	#$(INSTALL) -m 644 noipv6.1 $(man1dir)/noipv6

install-strip: install

uninstall:
	rm -f $(bindir)/noipv6
	rm -f $(libdir)/gaise/${MODULE}
	rm -f $(man1dir)/noipv6.1
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

dist:
	rm -rf gaise-${VERSION}
	mkdir gaise-${VERSION}
	cp COPYING Makefile README *.c noipv6.m4 noipv6.1 gaise-${VERSION} 
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
