#  install hyper for kvm/qemu

  wget -qO- https://hyper.sh/install | bash
  curl -sSL https://hyper.sh/install | bash

  or

  wget -O hyper-latest.tgz http://hyper-install.s3.amazonaws.com/hyper-latest.tgz
  tar xzvf hyper-latest.tgz
  cd hyper-pkg
  ./bootstrap.sh

