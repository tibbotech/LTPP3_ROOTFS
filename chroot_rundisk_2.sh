qemu_fpath=/usr/bin/qemu-arm-static
bash_fpath=/usr/bin/bash

cat << EOF | chroot ${qemu_fpath} ${bash_fpath}
	apt-get install -y bsdmainutils
EOF
