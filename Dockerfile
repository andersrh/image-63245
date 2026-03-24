FROM quay.io/almalinuxorg/atomic-desktop-kde:10

# This may be necessary for the speakers and internal microphone
RUN dnf install -y alsa-sof-firmware

RUN dnf install --nogpgcheck -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

RUN dnf config-manager --add-repo https://copr.fedorainfracloud.org/coprs/andersrh/sonicDE/repo/rhel+epel-10/andersrh-sonicDE-rhel+epel-10.repo -y
RUN dnf config-manager --add-repo https://copr.fedorainfracloud.org/coprs/g/xlibre/xlibre-xserver/repo/rhel+epel-10/group_xlibre-xlibre-xserver-rhel+epel-10.repo -y

RUN dnf install sonic-workspace-x11 sonic-win sonic-interface-libraries sonic-workspace --allowerasing -y

RUN dnf install -y fish distrobox nvtop intel-media-driver libva-intel-driver htop

# Remove plocate to avoid updatedb going crazy with scanning the file system once a day
RUN dnf remove -y plocate

# Install libheif-freeworld to show thumbnails in Dolphin
RUN dnf install libheif-freeworld -y

# Install proprietary codecs
RUN dnf swap libavcodec-free libavcodec-freeworld --allowerasing -y

# Install HPLIP for HP printer support
RUN dnf install hplip -y

RUN dnf -y install gwenview kalk okular
RUN dnf -y install chromium

# Add rule to SELinux allowing modules to be loaded into custom kernel
RUN setsebool -P domain_kernel_load_modules on

RUN dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
RUN dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

RUN rm -f /usr/lib64/libopenh264.so.2.4.1 /usr/lib64/libopenh264.so.7
RUN rpm -Uvh --nodeps https://codecs.fedoraproject.org/openh264/42/x86_64/Packages/o/openh264-2.5.1-1.fc42.x86_64.rpm https://codecs.fedoraproject.org/openh264/42/x86_64/Packages/m/mozilla-openh264-2.5.1-1.fc42.x86_64.rpm

RUN dnf install xlibre-xserver-Xorg xlibre-xf86-input-libinput xinput -y

# Install VLC
RUN dnf install vlc vlc-plugins-freeworld vlc-plugin-pipewire -y

RUN systemctl enable docker

COPY etc /etc

RUN cd /usr/bin && wget https://raw.githubusercontent.com/CachyOS/CachyOS-Settings/refs/heads/master/usr/bin/kerver && chmod +x kerver

RUN rm -rf /tmp/* /var/* && mkdir -p /var/tmp && chmod -R 1777 /var/tmp && \
    bootc container lint
