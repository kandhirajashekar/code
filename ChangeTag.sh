#!/bin/bash
sed "s/tagVersion/$1/g" Create-k8s-deployment.yaml > K8s-deployement.yaml