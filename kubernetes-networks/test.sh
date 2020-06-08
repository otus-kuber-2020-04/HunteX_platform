#!/bin/sh

minikube delete
minikube start

# 😄  minikube v1.9.2 on Darwin 10.15.5
# ✨  Automatically selected the hyperkit driver. Other choices: docker, virtualbox
# 👍  Starting control plane node m01 in cluster minikube
# 🔥  Creating hyperkit VM (CPUs=2, Memory=4000MB, Disk=20000MB) ...
# 🐳  Preparing Kubernetes v1.18.0 on Docker 19.03.8 ...
# 🌟  Enabling addons: default-storageclass, storage-provisioner
# 🏄  Done! kubectl is now configured to use "minikube"

# enable IPVS
kubectl --namespace kube-system edit configmap/kube-proxy

# restart kube-proxy
kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'

sleep 30

# install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

sleep 30

# check MetalLB
kubectl --namespace metallb-system get all

# apply MetalLB config
kubectl apply -f metallb-config.yaml

# add app
kubectl apply -f web-deploy.yaml

# add lb
# kubectl apply -f web-svc-lb.yaml

# add route ...
sudo route add 172.17.255.0/24 $(minikube ip)

# install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml

sleep 60

# apply nginx-lb
kubectl apply -f nginx-lb.yaml

sleep 30

# apply headless service
kubectl apply -f web-svc-headless.yaml

sleep 15

# apply web-ingress
kubectl apply -f web-ingress.yaml

sleep 30

# describe ingress
kubectl describe ingress/web

# get services
kubectl get svc -n ingress-nginx

# add dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml

# apply dashboard ingress
kubectl apply -f dashboard/web-ingress.yaml
