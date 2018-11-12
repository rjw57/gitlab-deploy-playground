#!/usr/bin/env bash
#
# Hackery required to work around issues.

# Move to this script's location
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Get k8s credentials
gcloud --project=$(cd project; terraform output project_id) \
    container clusters get-credentials \
    --region=$(cd project; terraform output region) \
    "$(cd infrastructure; terraform output cluster_name)"

# Create storage class - terraform does not yet support reclaimPolicy and
# allowVolumeExpansion.
kubectl apply -f storage_class.yaml

# Patch tiller deployment. The auto-install done by terraform does not like
# using a service account.
kubectl -n kube-system patch deployment tiller-deploy \
    -p '{"spec": {"template": {"spec": {"automountServiceAccountToken": true}}}}'

# Update helm dependencies
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm dependencies update charts/gitlab
