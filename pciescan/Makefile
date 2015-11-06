
PREFIX?=/usr/local/bin

all:
	gcc -o pciescanportal pciescanportal.c

install: all
	install -D -m4755 pciescanportal $(DESTDIR)$(PREFIX)/pciescanportal
	install -D -m755 pciescan.sh $(DESTDIR)$(PREFIX)/pciescan.sh

dpkg:
	git clean -fdx
	git buildpackage --git-upstream-branch=master --git-debian-branch=ubuntu/trusty --git-ignore-new -tc -us -uc

spkg:
	git clean -fdx
	sed -i s/precise/trusty/g debian/changelog
	git buildpackage --git-upstream-branch=master --git-debian-branch=ubuntu/trusty --git-ignore-new -tc -S
	sed -i s/trusty/precise/g debian/changelog
	git buildpackage --git-upstream-branch=master --git-debian-branch=ubuntu/trusty --git-ignore-new -tc -S
