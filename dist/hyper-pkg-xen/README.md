#  install hyper for xen

  wget -qO- https://hyper.sh/install-xen | bash
  curl -sSL https://hyper.sh/install-xen | bash

  or

  wget -O hyper-xen-latest.tgz http://hyper-install.s3.amazonaws.com/hyper-xen-latest.tgz
  tar xzvf hyper-xen-latest.tgz
  cd hyper-pkg-xen
  ./bootstrap.sh

