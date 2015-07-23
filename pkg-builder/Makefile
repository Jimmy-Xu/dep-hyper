#!/usr/bin/make -f

# Common package information.
include pkg-info

DESCRIPTION := $(shell git describe --tags --match 'v*' | cut -d'v' -f2-)
VERSION ?= $(shell echo $(DESCRIPTION) | cut -d'-' -f1)
RELEASE ?= $(shell echo $(DESCRIPTION) | cut -d'-' -f2- -s | tr '-' '.')
ARCH ?= $(shell uname -i)
INIT_SYS ?= $(shell  (which systemctl 2>/dev/null)|wc -l)

HYPER_DIR := $(GOPATH)/src/hyper
HYPERSTART_DIR := $(GOPATH)/src/hyperstart

TARGET_BIN="usr/local/bin"
TARGET_CONFIG="etc/hyper"
TARGET_RUNTIME="var/lib/hyper"
TARGET_LOG="var/log/hyper"

ifeq ($(VERSION),)
$(error No VERSION available, please set manually.)
endif
ifeq ($(RELEASE),)
RELEASE := 1
endif

ifeq ($(ARCH),x86_64)
DEB_ARCH := amd64
RPM_ARCH := x86_64
KERNEL_ARCH := x86
else
	ifeq ($(ARCH),386)
		$(error Support arch "$(ARCH)" only.)
	else
		$(error Unknown arch "$(ARCH)".)
	endif
endif

ifeq ($(INIT_SYS),1)
    SRC_INIT_FILE="service/systemd/hyperd.service"
    TGT_INIT_FILE="lib/systemd/system/hyperd.service"
    TGT_INIT_DIR="lib/systemd/system/"
else
    SRC_INIT_FILE="service/init.d/hyperd.centos"
    TGT_INIT_FILE="etc/init.d/hyperd"
    TGT_INIT_DIR="etc/init.d/"
endif

clean:
	@rm -rf debbuild/ rpmbuild/ *.deb *.rpm
	@echo -n > dist/lib/systemd/system/hyperd.service
	@echo -n > dist/etc/init.d/hyperd
	@echo -n > dist/usr/local/bin/hyper
	@echo -n > dist/usr/local/bin/hyperd
	@echo -n > dist/var/lib/hyper/kernel
	@echo -n > dist/var/lib/hyper/hyper-initrd.img
.PHONY: clean

dist:
	@cp ${HYPER_DIR}/hyper ${HYPER_DIR}/hyperd dist/usr/local/bin
	@cp ${HYPERSTART_DIR}/build/hyper-initrd.img ${HYPERSTART_DIR}/build/kernel dist/var/lib/hyper
	@mkdir -p dist/$(TGT_INIT_DIR)
	@cp $(SRC_INIT_FILE) dist/$(TGT_INIT_FILE)
.PHONY: dist

check:
	@ls -l --color dist/usr/local/bin/ dist/var/lib/hyper/ dist/lib/systemd/system/hyperd.service dist/etc/init.d/hyperd
.PHONY: check

deb: dist
	@rm -rf debbuild && mkdir -p debbuild/
	@rsync -ruav dist/*  debbuild/
	@rsync -ruav packagers/DEBIAN debbuild/
	@chmod 755 debbuild/DEBIAN
	@sed -i "s/VERSION/$(VERSION)-$(RELEASE)/" debbuild/DEBIAN/control
	@sed -i "s/MAINTAINER/$(MAINTAINER)/" debbuild/DEBIAN/control
	@sed -i "s/ARCHITECTURE/$(DEB_ARCH)/" debbuild/DEBIAN/control
	@sed -i "s/SUMMARY/$(SUMMARY)/" debbuild/DEBIAN/control
	@sed -i "s#URL#$(URL)#" debbuild/DEBIAN/control
	@fakeroot dpkg -b debbuild/ .
.PHONY: deb

rpm: dist
	@rm -rf rpmbuild && mkdir -p rpmbuild
	@rpmbuild -bb --buildroot $(PWD)/rpmbuild/BUILDROOT \
	  --define="%_topdir $(PWD)/rpmbuild" \
	  --define="%version $(VERSION)" \
	  --define="%release $(RELEASE)" \
	  --define="%maintainer $(MAINTAINER)" \
	  --define="%architecture $(RPM_ARCH)" \
	  --define="%summary $(SUMMARY)" \
	  --define="%url $(URL)" \
	  packagers/hyper.spec
	@mv rpmbuild/RPMS/$(RPM_ARCH)/*.rpm .
.PHONY: rpm

packages: deb rpm
.PHONY: packages

