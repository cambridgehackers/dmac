include Makefile.version

all:
	$(MAKE) -C src
	$(MAKE) -C example

DISTDIR=../dmac-$(VERSION)

dist:
	mkdir -p $(DISTDIR)/
	rsync -avz --delete --exclude=.git src example $(DISTDIR)
	rsync -avz --delete --exclude=.git ../connectal $(DISTDIR)
	rsync -avz --delete --exclude=.git ../fpgajtag $(DISTDIR)
	rsync -avz --delete --exclude=.git ../pciescan $(DISTDIR)
	cp Makefile.version $(DISTDIR)
	cp Makefile.dist $(DISTDIR)/Makefile

build:
	$(MAKE) -C $(DISTDIR) all

distinstall:
	$(MAKE) -C $(DISTDIR) install

TDIST := $(PWD)/../tdist

disttest:
	cd $(DISTDIR); make DESTDIR=$(TDIST) PREFIX=/usr all install test

