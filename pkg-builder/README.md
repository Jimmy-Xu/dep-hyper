#################################################
# Repo Structure

    .
    ├── dist
    │   ├── etc
    │   │   ├── hyper
    │   │   │   └── config
    │   │   └── init.d
    │   │       └── hyperd
    │   ├── lib
    │   │   └── systemd
    │   │       └── system
    │   │           └── hyperd.service
    │   ├── usr
    │   │   └── local
    │   │       └── bin
    │   │           ├── hyper
    │   │           └── hyperd
    │   └── var
    │       ├── lib
    │       │   └── hyper
    │       │       ├── bios-qboot.bin
    │       │       ├── cbfs-qboot.rom
    │       │       ├── hyper-initrd.img
    │       │       └── kernel
    │       └── log
    │           └── hyper
    ├── Makefile
    ├── packagers
    │   ├── DEBIAN
    │   │   ├── changelog
    │   │   ├── control
    │   │   ├── README.Debian
    │   │   └── rules
    │   └── hyper.spec
    ├── pkg-info
    ├── README.md
    └── service
        ├── init.d
        │   ├── hyperd.centos
        │   └── hyperd.ubuntu
        └── systemd
            └── hyperd.service

#################################################
# dependency

- install rpmbuild under ubuntu/debian to build rpm  
`sudo apt-get install rpm`

- install dpkg under centos/fedora to build deb  
`sudo yum install dpkg`


#################################################
# Build deb for Debian/Ubuntu

- build deb  
`make deb`

- install deb  
`sudo dpkg -i hyper_0.1-5.g56fd622_amd64.deb`

- uninstall deb  
`sudo dpkg -P hyper`

# Build rpm for CentOS/Fedora

- build rpm  
`make rpm`

- install rpm  
`rpm -ivh hyper-0.1-5.g56fd622.x86_64.rpm`

- uninstall rpm  
`rpm -e hyper-0.1-5.g56fd622.x86_64`
