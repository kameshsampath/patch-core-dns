FROM alpine

COPY patch-coredns.sh /patch-coredns.sh
COPY find-and-verify-kubectl.sh /find-and-verify-kubectl.sh

RUN apk add --no-cache bash curl \
    && curl -sSL https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 -o yq \
    && chmod +x yq \
    && mv yq /usr/local/bin \
    && chmod +x /patch-coredns.sh /find-and-verify-kubectl.sh

CMD [ "/patch-coredns.sh" ]
