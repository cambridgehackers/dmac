
PREFIX?=/usr/local
CONNECTALDIR?=connectal

all: bsvtops
	$(MAKE) BOARD=vc709 libdmac-vc709.a
	$(MAKE) BOARD=kc705g2 libdmac-kc705g2.a
	$(MAKE) BOARD=bluesim libdmac-bluesim.a

install: all
	install -d -m755 $(DESTDIR)$(PREFIX)/include/dmac $(DESTDIR)$(PREFIX)/lib $(DESTDIR)$(PREFIX)/share/dmac/bsv $(DESTDIR)$(PREFIX)/share/dmac/tcl
	install -m644 Makefile.dmac $(DESTDIR)$(PREFIX)/share/dmac
	install -m644 dmac.h $(DESTDIR)$(PREFIX)/include/dmac
	install -m644 lib*.* $(DESTDIR)$(PREFIX)/lib
	install -m644 *.bsv generated/*.bsv $(DESTDIR)$(PREFIX)/share/dmac/bsv
	install -m644 pciecore.tcl $(DESTDIR)$(PREFIX)/share/dmac/tcl

clean:
	rm -fr lib*.so lib*.a obj*

bsvtops: generated/BsimTop.bsv generated/PcieTop.bsv

generated/%.bsv: $(CONNECTALDIR)/bsv/%.bsv
	cp -fv $< $@
	sed -i 's/import Top *::/import ConnectalTop::/' $@

PORTAL_INFRA := portal.c transportHardware.c transportSocket.c portalJson.c portalPrintf.c poller.cpp sock_utils.c timer.c dmaManager.c platformMemory.cpp BsimCtrl.cpp BsimDma.cpp
GENERATED_CPP=GeneratedCppCallbacks.cpp MemServerRequest.c MemServerRequestJson.c MMURequest.c MMURequestJson.c MemServerIndication.c MemServerIndicationJson.c MMUIndication.c MMUIndicationJson.c DmaRequest.c DmaRequestJson.c DmaIndication.c DmaIndicationJson.c
PORTAL_SRC_FILES := $(addprefix $(CONNECTALDIR)/cpp/, $(PORTAL_INFRA)) \
                    $(addprefix generated/, $(GENERATED_CPP))
SOURCES = ../src/dmac.cpp $(PORTAL_SRC_FILES)
OBJECTS = $(addsuffix .o, $(PORTAL_INFRA) $(GENERATED_CPP))

CFLAGS = -I../src -I$(CONNECTALDIR)/cpp -I../src/generated -I$(CONNECTALDIR) -DBOARD_$(BOARD)
ifeq ($(BOARD),bluesim)
CFLAGS += -DSIMULATION
endif

CPP_SOURCES = $(filter %.cpp, $(SOURCES))
C_SOURCES = $(filter %.c, $(SOURCES))

define cpp_obj_file
$(addprefix obj-$(BOARD)/, $(notdir $(patsubst %.cpp, %.o, $(1))))
endef
define c_obj_file
$(addprefix obj-$(BOARD)/, $(notdir $(patsubst %.c, %.o, $(1))))
endef
define cpp_rule
$(call cpp_obj_file, $(1)): $(1)
	$(Q)mkdir -p obj-$(BOARD)
	g++ $(CFLAGS) -fPIC -c -o $(call cpp_obj_file, $(1)) $(1)
endef
define c_rule
$(call c_obj_file, $(1)): $(1)
	$(Q)mkdir -p obj-$(BOARD)
	g++ $(CFLAGS) -fPIC -c -o $(call c_obj_file, $(1)) $(1)
endef

CPP_OBJ_FILES = $(call cpp_obj_file, $(CPP_SOURCES))
C_OBJ_FILES = $(call c_obj_file, $(C_SOURCES))
PORTAL_OBJ_FILES = $(CPP_OBJ_FILES) $(C_OBJ_FILES)

$(foreach cpp, $(CPP_SOURCES), $(eval $(call cpp_rule, $(cpp))))
$(foreach c, $(C_SOURCES), $(eval $(call c_rule, $(c))))

libdmac-$(BOARD).a: $(PORTAL_OBJ_FILES)
	$(Q)rm -f libdmac-$(BOARD).a
	ar cr libdmac-$(BOARD).a $(PORTAL_OBJ_FILES)
	ranlib libdmac-$(BOARD).a

libdmac-%.so: $(PORTAL_SRC_FILES)
	$(Q)g++ -shared -fpic $(CFLAGS) -o $@ $(SOURCES)
