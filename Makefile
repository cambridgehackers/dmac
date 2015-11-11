
CURRENTDIR := $(realpath .)
PREFIX?=/usr/local
BINDIR?=$(PREFIX)/bin
CONNECTALDIR?=src/connectal
include Makefile.version

all:
	$(MAKE) -C fpgajtag all
	$(MAKE) -C pciescan all
	$(MAKE) -C src      all

dependences:
	apt-get install zlib1g-dev libusb-1.0-0-dev

.PHONY: example

example:
	$(MAKE) -C example

install: all
	install -d -m755 $(DESTDIR)$(BINDIR)
	$(MAKE) PREFIX=$(PREFIX) -C fpgajtag install
	chmod u+s $(DESTDIR)$(PREFIX)/bin/fpgajtag
	$(MAKE) -C pciescan PREFIX=$(PREFIX)/bin install
	$(MAKE) -C src      install
	cd $(CONNECTALDIR)/drivers/pcieportal; $(MAKE) CONNECTALDIR=$(CURRENTDIR) PKG_NAME=dmac install-dkms
	install -D -m644 $(CONNECTALDIR)/etc/udev/rules.d/99-pcieportal.rules $(DESTDIR)/etc/udev/rules.d/99-pcieportal.rules
	install -m644 $(CONNECTALDIR)/bsv/*.bsv $(DESTDIR)$(PREFIX)/share/dmac/bsv
	install -d -m755 $(DESTDIR)$(PREFIX)/share/dmac/constraints
	install -m644 $(CONNECTALDIR)/constraints/* $(DESTDIR)$(PREFIX)/share/dmac/constraints
	install -d -m755 $(DESTDIR)$(PREFIX)/share/dmac/verilog
	install -m644 $(CONNECTALDIR)/verilog/PositiveReset.v $(DESTDIR)$(PREFIX)/share/dmac/verilog
	install -m755 $(CONNECTALDIR)/pcie/pcieflat $(DESTDIR)$(PREFIX)/bin/pcieflat
	install -D -m755 $(CONNECTALDIR)/etc/modules-load.d/connectal.conf $(DESTDIR)/etc/modules-load.d/connectal.conf
ifeq ("$(DESTDIR)","")
	echo dkms
	dkms add build install -m dmac -v $(VERSION) --verbose
endif

uninstall:
	rm -fv $(DESTDIR)$(PREFIX)/bin/fpgajtag*
	rm -fv $(DESTDIR)$(PREFIX)/bin/pcieflat
	rm -fv $(DESTDIR)$(PREFIX)/bin/pciescan*
	rm -fv $(DESTDIR)/etc/udev/rules.d/99-pcieportal.rules
	rm -fv $(DESTDIR)/etc/modules-load.d/connectal.conf
	rm -fv $(DESTDIR)$(PREFIX)/include/dmac/dmac.h
	rm -fv $(DESTDIR)$(PREFIX)/lib/libdmac-*.*
	rm -fvr $(DESTDIR)$(PREFIX)/share/dmac
ifeq ("$(DESTDIR)","")
	dkms remove -m dmac -v $(VERSION) --verbose --all
endif
	rm -fvr $(DESTDIR)/usr/src/dmac-*

test:
	#cd example; $(MAKE) PREFIX=$(PREFIX)

connectalsrc:
	mkdir -p src/connectal/cpp src/connectal/bsv src/connectal/drivers/portalmem src/connectal/drivers/pcieportal src/connectal/verilog src/connectal/constraints
	cp ../connectal/bsv/*.bsv src/connectal/bsv
	cp ../connectal/lib/bsv/*.bsv src/connectal/bsv
	cp ../connectal/generated/xilinx/*.bsv src/connectal/bsv
	cp ../connectal/cpp/* src/connectal/cpp
	mkdir -p src/connectal/etc/udev/rules.d src/connectal/etc/modules-load.d
	cp -r ../connectal/etc/udev/rules.d src/connectal/etc/udev/
	cp -r ../connectal/etc/modules-load.d src/connectal/etc/
	mkdir -p src/connectal/generated/cpp src/connectal/scripts src/connectal/pcie
	cp ../connectal/scripts/driver_signature.sed src/connectal/scripts
	cp ../connectal/pcie/pcieflat src/connectal/pcie
	cp ../connectal/generated/cpp/* src/connectal/generated/cpp
	cp -r ../connectal/drivers/portalmem/* src/connectal/drivers/portalmem
	cp -r ../connectal/drivers/pcieportal/* src/connectal/drivers/pcieportal
	cp ../connectal/verilog/*.v src/connectal/verilog
	cp ../connectal/constraints/xilinx/*.xdc src/connectal/constraints
	rsync -av --exclude=.git --delete ../fpgajtag .
	rsync -av --exclude=.git --delete ../pciescan .

publish:
	cd doc; rm -fr build; make html latexpdf
	rm -fr ../dmac-$(VERSION)
	git clone . ../dmac-$(VERSION)
	cp -fv example/mkExample.bit ../dmac-$(VERSION)/example
	cp -fv doc/build/latex/dmac.pdf ../dmac-$(VERSION)/doc
	rsync -av doc/build/html ../dmac-$(VERSION)/doc
	mkdir -p manifests
	repo manifest -r -o manifests/manifest-$(VERSION).xml
	rsync -av manifests ../dmac-$(VERSION)/
	cd ..; tar -zcvf ../dmac-$(VERSION).tar.gz dmac-$(VERSION)
