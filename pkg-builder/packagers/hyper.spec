Name: hyper
Summary: %{summary}
Version: %{version}
Release: %{release}
Group: System
License: ASL 2.0
URL: %{url}
Packager: %{maintainer}
BuildArch: %{architecture}
BuildRoot: %{_tmppath}/%{name}.%{version}-buildroot
Requires: qemu, fakeroot


#set the algorithm explicitly to MD5SUM
%global _binary_filedigest_algorithm 1


%description
%{summary}


%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT
rsync -rav --delete ../../dist/* $RPM_BUILD_ROOT


%files
/etc/hyper/config
/usr/local/bin/hyper
/usr/local/bin/hyperd
/var/lib/hyper/kernel
/var/lib/hyper/hyper-initrd.img
/var/lib/hyper/bios-qboot.bin
/var/lib/hyper/cbfs-qboot.rom
/etc/init.d/hyperd
/lib/systemd/system/hyperd.service


%changelog
* Wed Jun 3 2015 Jimmy Xu <xjimmyshcn@gmail.com>
- Initial package creation
