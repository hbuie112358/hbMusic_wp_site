# The throwaway server of bin/deploy's test (dev-deploy-server.sh, template plan 1.4d-3), set up
# like the host: one account, reached only by keys, each key forced into rsync's daemon mode with
# its own folder settings, which the test copies in. The image and both packages are pinned in
# tools/versions.sh and passed in as build arguments.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG OPENSSH_SERVER_VERSION
ARG RSYNC_VERSION
# The account's password is "*", which matches nothing, so only keys can log in.
RUN apk add --no-cache "openssh-server=${OPENSSH_SERVER_VERSION}" "rsync=${RSYNC_VERSION}" \
    && adduser -D -h /home/deploy deploy \
    && echo 'deploy:*' | chpasswd -e \
    && mkdir -p /srv /home/deploy/.deploy \
    && chown deploy:deploy /home/deploy/.deploy
COPY sshd_config /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D", "-e"]
