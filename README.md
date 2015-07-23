# Guide for update hyper install package

## Content
   - How to start Text UI
   - Text UI Menu summary
   - How to install dependency
      - How to install proxy
      - How to install s3 cli
   - How to update install package
   - How to test install package
   - Difference between hyper for kvm/qemu and xen


## How to start Text UI

$ git clone https://github.com/getdvm/hyper-installer.git  
$ cd hyper-installer  
$ ./hyper-tool.sh  

 **Support OS**

 - ubuntu 14.04
 - debian 8(jessie)
 - centos 7
 - fedora 22


## Text UI Menu summary

 - 1   **Install dependency**
   - 1.1   shadowsocks
     - 1.1.1   *`Install shadowsocks`
     - 1.1.2   *`Config shadowsocks`
     - 1.1.3   Check shadowsocks
     - 1.1.4   Start shadowsocks
     - 1.1.5   Stop shadowsocks
   - 1.2   privoxy
     - 1.2.1   *`Install privoxy`
     - 1.2.2   *`Config privoxy`
     - 1.2.3   Check privoxy
     - 1.2.4   Start privoxy
     - 1.2.5   Stop privoxy
   - 1.3   awscli
     - 1.3.1   *`Install awscli`
     - 1.3.2   *`Config awscli`
     - 1.3.3   Check awscli
   - 1.4   s3cmd
     - 1.4.1   *`Install s3cmd`
     - 1.4.2   *`Config s3cmd`
     - 1.4.3   Check s3cmd
 - 2   **Manage proxy**
   - 2.1   Check
   - 2.2   *`Enable proxy`
   - 2.3   *`Disable proxy`
 - 3   **Update install package for kvm**
   - 3.1   Pull dev package
   - 3.2   Push dev package
   - 3.3   *`Pull live package`
   - 3.4   *`Push live package`
   - 3.5   Clean
 - 4   **Update install package for xen**
   - 4.1   Pull dev package
   - 4.2   Push dev package
   - 4.3   *`Pull live package`
   - 4.4   *`Push live package`
   - 4.5   Clean
 - 5   **Install hyper**
   - 5.1   Install hyper in dev mode
   - 5.2   *`Install hyper in live mode`
   - 5.3   clean install tmp dir


## How to update install package

### Step 1 install proxy

#### description  

   upload file to s3 with proxy will be easy.

   Here is a proxy solution: `shadowsocks`(socks5 proxy) + `privoxy`(convert http request to socks5)


#### operation  
      1.1.1 + 1.1.2 + 1.2.1 + 1.2.2


#### shadowsocks

   - **shadowsocks serivce**  
      `sysvinit`: /etc/init.d/sslocal  
      `systemd`:  /lib/systemd/system/sslocal.service

   - **shadowsocks config**  
      ./etc/shadowsocks/client.json => /etc/shadowsocks/client.json

   - **shadowsocks log**  
      `sysvinit`: /var/log/sslocal.log  
      `systemd`: sudo service sslocal status


#### privoxy

   - **privoxy service**  
      `sysvinit`: /etc/init.d/privoxy  
      `systemd`: /lib/systemd/system/privoxy.service

   - **privoxy config**  
      /etc/privoxy/config




### Step 2 install s3 cli

#### description  

   Choose one of these two : `awscli`(no progress) or `s3cmd`(has progress)

#### operation

      1.3.1 + 1.3.2 or 1.4.1 + 1.4.2

#### awscli

   - **awscli configure**  
      $ `aws configure --profile hyper`

   - configure item  
      just get `Access Key ID` and `Secret Access ID` from https://trello.com/c/A7c7KDye/32-aws-credential-for-hyper

   - **awscli config file**  
      ~/.aws/config  
      ~/.aws/credentials

#### s3cmd

   - **s3cmd configure**  
      $ `s3cmd --configure`

   - configure item  
      just get `Access Key ID` and `Secret Access ID` from https://trello.com/c/A7c7KDye/32-aws-credential-for-hyper

   - **s3cmd config file**  
      ~/.s3cfg



### Step 3 enable/disable proxy

#### description  

   - Enalbe proxy  
      start sslocal and privoxy service

   - Disable proxy  
      stop sslocal and privoxy service

   `The following steps will auto detect proxy, if sslocal and privoxy is running, then use proxy, otherwise no proxy.`

#### operation

      2.2 / 2.3


### Step 4 pull install package from s3

#### description  

   download live install package from s3, then untar package.

#### operation

      3.3(kvm) / 4.3(xen)

#### download dir

      ./dist/

#### untar dir

      ./dist/hyper-dev


### Step 5 replace with new version file

#### description  

   replace file under ./dist/hyper-dev/bin/ or ./dist/hyper-dev/boot/

   - update `hyper` or `hyperd`  
    find old file under ./dist/hyper-dev/bin/, just replace with new files.

   - update `qboot`, `initrd` and `kernel`  
    find old file under ./dist/hyper-dev/boot/, just replace with new files.


### Step 6 push install package to s3

#### description  

   re-tar install package, then upload to s3.

#### operation

      3.4(kvm) / 4.4(xen)


### Step 7 test new install package

#### description  

   run local hyper install script(`hyper-bootstrap.sh`) to test new install package on s3.

#### operation

      5.2


## Difference between hyper for kvm/qemu and xen

### Hyper for kvm/qemu:
 1. Support **qboot**, so there are `cbfs-qboot.rom` and `bios-qboot.bin` in install package
 2. Install with "./install.sh"
 3. There are `Bios` and `Cbfs` parameters in `/etc/hyper/config`
 4. Install with `curl -sSL https://hyper.sh/install | bash`
 5. Install package url: http://hyper-install.s3.amazonaws.com/hyper-latest.tgz


### Hyper for xen:
 1. Doesn't support **qboot**, so no `cbfs-qboot.rom` and `bios-qboot.bin` in install package
 2. Install with "./install.sh `--disable-qboot`"
 3. No `Bios` and `Cbfs` parameters in `/etc/hyper/config`
 4. Install with `curl -sSL https://hyper.sh/install-xen | bash`
 5. Install package url: http://hyper-install.s3.amazonaws.com/hyper-xen-latest.tgz

### Test mode of install
 - bash <(curl -sSL https://hyper.sh/install) --dev
  - http://hyper-install-dev.s3.amazonaws.com/hyper-latest-dev.tgz
 - bash <(curl -sSL https://hyper.sh/install-xen) --dev
  - http://hyper-install-dev.s3.amazonaws.com/hyper-xen-latest-dev.tgz

### Difference of bootstrap script
    --- hyper-installer\hyper-bootstrap-xen.sh
    +++ hyper-installer\hyper-bootstrap.sh
    @@ -2,12 +2,12 @@
     # Description:  This script is used to install hyper cli and hyperd
     # Usage:
     #  install from remote
    -#    wget -qO- https://hyper.sh/install-xen | bash
    -#    curl -sSL https://hyper.sh/install-xen | bash
    +#    wget -qO- https://hyper.sh/install | bash
    +#    curl -sSL https://hyper.sh/install | bash
     # install from local
     #    ./bootstrap.sh
     BASE_DIR=$(cd "$(dirname "$0")"; pwd); cd ${BASE_DIR}
    -DEV_MODE=""; SLEEP_SEC=10; SUPPORT_XEN="-xen";
    +DEV_MODE=""; SLEEP_SEC=10; SUPPORT_XEN="";
     if [ $# -eq 1 -a "$1" == "--dev" ];then
       DEV_MODE="-dev"; SLEEP_SEC=3; echo "[test mode]"
     fi
    @@ -335,7 +335,7 @@
       show_message info "Installing "
       set +e
       cd ${BOOTSTRAP_DIR}
    -  ${BASH_C} "./install.sh --disable-qboot" 1>/dev/null
    +  ${BASH_C} "./install.sh" 1>/dev/null
       if [ $? -ne 0 ];then
         show_message error "${ERR_EXEC_INSTALL_FAILED[1]}" && exit "${ERR_EXEC_INSTALL_FAILED[0]}"
       fi
