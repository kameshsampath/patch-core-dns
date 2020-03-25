FROM registry.access.redhat.com/ubi8/ubi-minimal:8.1

COPY patch-coredns.sh /patch-coredns.sh
COPY find-and-verify-kubectl.sh /find-and-verify-kubectl.sh

RUN microdnf install findutils \  
    &&curl -sSL https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 -o yq \
    && chmod +x yq \
    && mv yq /usr/local/bin \
    && chmod +x /patch-coredns.sh /find-and-verify-kubectl.sh

CMD [ "/patch-coredns.sh" ]
