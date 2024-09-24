#!/bin/bash
: -
echo "::add-mask::https://"
SRC_URI=(
  https://code.qt.io/yocto/meta-qt6.git
  https://git.openembedded.org/bitbake
  https://git.openembedded.org/meta-openembedded
  https://git.openembedded.org/meta-openembedded-contrib
  https://git.openembedded.org/openembedded-core
  https://git.yoctoproject.org/git/meta-mingw
  https://git.yoctoproject.org/meta-amd
  https://git.yoctoproject.org/meta-arm
  https://git.yoctoproject.org/meta-cloud-services
  https://git.yoctoproject.org/meta-dpdk
  https://git.yoctoproject.org/meta-intel
  https://git.yoctoproject.org/meta-lts-mixins
  https://git.yoctoproject.org/meta-security
  https://git.yoctoproject.org/meta-selinux
  https://git.yoctoproject.org/meta-tensorflow
  https://git.yoctoproject.org/meta-ti
  https://git.yoctoproject.org/meta-virtualization
  https://git.yoctoproject.org/meta-yocto
  https://git.yoctoproject.org/poky
  https://git.yoctoproject.org/poky-contrib
  https://github.com/agherzan/meta-raspberrypi.git
  https://github.com/foundriesio/meta-xilinx-tools.git
  https://github.com/foundriesio/meta-xilinx.git
  https://github.com/Freescale/meta-freescale-3rdparty.git
  https://github.com/Freescale/meta-freescale.git
  https://github.com/KDE/yocto-meta-kde.git
  https://github.com/KDE/yocto-meta-kf5.git
  https://github.com/KDE/yocto-meta-kf6.git
  https://github.com/kraj/meta-clang.git
  https://github.com/linux-sunxi/meta-sunxi.git
  https://github.com/meta-qt5/meta-qt5.git
  https://github.com/meta-rust/meta-rust.git
  https://github.com/OE4T/meta-tegra.git
  https://github.com/riscv/meta-riscv.git
  https://github.com/STMicroelectronics/meta-st-stm32mp.git
  https://github.com/tailscale/tailscale.git
  https://github.com/uptane/meta-updater.git
  https://github.com/veracrypt/VeraCrypt-DCS.git
  https://github.com/veracrypt/VeraCrypt.git
  https://github.com/Wind-River/meta-secure-core.git
  https://github.com/zehome/MLVPN.git
  https://src.libcode.org/pkun/faux.git
  https://src.libcode.org/pkun/klish.git
)
: -
errors=0
for src_uri in ${SRC_URI[*]} ; do
  src_name=$(basename $src_uri .git | tr '[:upper:]' '[:lower:]')
  dst_uri="https://github.com/distro-core-curated-mirrors/$src_name.git"
  touch git-clone.log
  rm -fr $src_name
  if git clone --mirror $src_uri $src_name >git-clone.log; then
    echo "Success git clone $src_uri"
    touch git-push.log
    cd $src_name
    git for-each-ref --format "delete %(refname)" refs/pull | git update-ref --stdin
    git for-each-ref --format "delete %(refname)" refs/meta | git update-ref --stdin
    git for-each-ref --format "delete %(refname)" refs/merge-requests | git update-ref --stdin
    git for-each-ref --format "delete %(refname)" refs/reviewable | git update-ref --stdin
    git for-each-ref --format "delete %(refname)" 'refs/tags/cicd*' | git update-ref --stdin
    if git push --porcelain --mirror $dst_uri >>../git-push.log; then
      echo "Success git push $dst_uri"
    else
      errors=$(( errors + 1 ))
      echo "::warning::🟥Failure git push $dst_uri"
    fi
    cd ..
    grep -v "\[up to date\]" git-push.log
    rm -f git-push.log
  else
    errors=$(( errors + 1 ))
    echo "::warning::🟥Failure git clone $src_uri"
  fi
  rm -fr $src_name
  rm -f git-clone.log
done
if [[ $errors -gt 0 ]]; then
  echo "::error::🟥Completed with failures"
  exit 1
fi
echo "::notice::🟢Completed"
