FROM alpine:3

ARG default_ssh_key
ARG motd

ENV PYTHONUNBUFFERED=1

RUN set -eux; \
    \
    apk add --no-cache \
            bind-tools \
            openrc \
            openssh \
            ca-certificates \
            su-exec \
            wget \
            curl \
            vim \
            rsync \
            tmux \
            jq \
            tree \
            unzip \
            zip \
            git \
            ffmpeg \
            flac \
            socat \
            mosh \
            ruby \
            mariadb-client \
            postgresql-client \
    ; \
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    && sed -i \
        # Change subsystem type to "docker"
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        # Define extra dependencies for services
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop \
    # Can't do cgroups
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
    && sed -i 's/#UseDNS .*/UseDNS no/g' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#AllowTcpForwarding .*/AllowTcpForwarding yes/g' /etc/ssh/sshd_config \
    && mkdir /root/.ssh \
    && echo "${default_ssh_key}" >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh \
    && chmod 644 /root/.ssh/authorized_keys \
    && echo "root:$(date +%s | sha256sum | base64 | head -c 8)" | chpasswd \
    && printf "\n${motd}\n\n" > /etc/motd \
    && printf "gem: --no-document" > /root/.gemrc \
    ; \
    rc-update add sshd

RUN cd /tmp && wget -O /tmp/speedtest.tar.gz https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-x86_64.tgz \
    && tar -xzvf speedtest.tar.gz \
    && mv speedtest /usr/local/bin/ \
    && rm -rf /tmp/speedtest* \
    ; \
    wget -O /tmp/mmv.tar.gz https://github.com/itchyny/mmv/releases/download/v0.1.4/mmv_v0.1.4_linux_amd64.tar.gz \
    && tar -xzvf /tmp/mmv.tar.gz \
    && mv /tmp/mmv_v0.1.4_linux_amd64/mmv /usr/local/bin/ \
    && chmod +x /usr/local/bin/mmv \
    && rm -rf /tmp/mmv_v0.1.4_linux_amd64 \
    && rm /tmp/mmv.tar.gz \
    && echo "export EDITOR=vim" >> /etc/profile \
    ; \
    curl -fsSL https://gist.githubusercontent.com/kwatson/45a298891981e2323eed3e118a3d5da7/raw/ff7eb5ba7afbccb11df6470290ab6f520c2a128d/.tmux.conf > /root/.tmux.conf \
    ; \
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

EXPOSE 22/tcp

CMD ["/sbin/init"]
