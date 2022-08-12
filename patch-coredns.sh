#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

set -o pipefail 

shopt -s expand_aliases

# check kubectl command
kubectl version

# clean up old files if they exist
rm -f /tmp/coredns-alias-patch.yaml
rm -f /tmp/coredns-alias-prepatch.yaml

OLDIFS=$IFS

IFS=', ' read -r -a ARR_REGISTRY_ALIASES <<< "${REGISTRY_ALIASES}"

ALIASES_ENTRIES=""
NL_DELIMITER='~'
SPACES='  '
RW_RULE='rewrite name '


IFS=

# store the previous value for further processing 
kubectl get cm coredns -n kube-system -oyaml | yq '.data.Corefile' -   | tee /tmp/coredns-alias-prepatch.yaml > /dev/null

nStart=$(grep -n -m 1 "$REGISTRY_SVC"  /tmp/coredns-alias-prepatch.yaml | head -n1 | cut -d: -f1 || true )
nEnd=$(grep -n "$REGISTRY_SVC" /tmp/coredns-alias-prepatch.yaml | tail -n1 | cut -d: -f1 || true )

#echo "Pattern Start line: $nStart Ending line : $nEnd"

# remove old entries 
if [ -n "$nStart" ] && [ -n "$nEnd" ]; 
then
   sed -i "$nStart,${nEnd}d" /tmp/coredns-alias-prepatch.yaml > /dev/null
fi

IFS=$OLDIFS

for H in "${ARR_REGISTRY_ALIASES[@]}"; 
do    
    [ -n  "$ALIASES_ENTRIES" ] && ALIASES_ENTRIES="$ALIASES_ENTRIES$NL_DELIMITER"
    ALIASES_ENTRIES="$ALIASES_ENTRIES$RW_RULE$H$SPACES$REGISTRY_SVC"
done

ALIASES_ENTRIES="$ALIASES_ENTRIES$NL_DELIMITER"

IFS=

if [ -n "$ALIASES_ENTRIES" ];
then
  # Add the rename rewrites after string health
  sed "/health/i\\
    $ALIASES_ENTRIES" < /tmp/coredns-alias-prepatch.yaml | tr '~' '\n' | tee /tmp/coredns-alias-patch.yaml > /dev/null
  JSON_PATCH=$(yq --null-input '(.data.Corefile = load("/tmp/coredns-alias-patch.yaml"))')
  printf " Applying patch %s" "$JSON_PATCH"
  kubectl patch cm coredns -n kube-system --patch "$JSON_PATCH"
  kubectl rollout status -n kube-system deployment coredns --timeout=30s
else
  echo "No Aliass entries found, skipping patch"
fi 
