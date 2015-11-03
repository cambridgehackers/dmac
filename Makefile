include Makefile.version

all:
	$(MAKE) -C src
	$(MAKE) -C example

DISTDIR=../dmac-$(VERSION)

dist:
	make -C doc
	mkdir -p $(DISTDIR)/
	rsync -avz --delete --exclude=.git doc/build/html/* $(DISTDIR)/doc
	rsync -avz --delete --exclude=.git doc/build/latex/dmac.pdf $(DISTDIR)/doc
	rsync -avz --delete --exclude=.git debian src example $(DISTDIR)
	rsync -avz --delete --exclude=.git ../connectal $(DISTDIR)
	rsync -avz --delete --exclude=.git ../fpgajtag $(DISTDIR)
	rsync -avz --delete --exclude=.git ../pciescan $(DISTDIR)
	cp Makefile.version $(DISTDIR)
	cp Makefile.dist $(DISTDIR)/Makefile

dist_tgz:
	rm -fr $(DISTDIR)
	make dist
	tar -zcf $(DISTDIR).tar.gz -C `dirname $(DISTDIR)` `basename $(DISTDIR)`

build:
	$(MAKE) -C $(DISTDIR) all

distinstall:
	$(MAKE) -C $(DISTDIR) install

TDIST := $(PWD)/../tdist

disttest:
	cd $(DISTDIR); make DESTDIR=$(TDIST) all install; (cd $(DISTDIR)/example; make DESTDIR=$(TDIST))

testinstall:
	@rm -fr $(TDIST)
	cd $(DISTDIR); make DESTDIR=$(TDIST) install uninstall
	@find $(TDIST) -type d
	@find $(TDIST) -type f || echo 'stray files left by uninstall'
