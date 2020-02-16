# Core DNS Patcher Job

The minikube registry helper addon requires the Kubernetes coreDNS to be patched after the registry aliases daemonset has completed updating the `/etc/hosts` of the minikube node.


## Open Issues

- rollback
- delta in merging
