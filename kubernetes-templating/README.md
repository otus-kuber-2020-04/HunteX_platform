# ДЦ "Шаблонизация манифестов"

> Создаем managed kubernetes кластер в GCP
> Устанавливаем gcloud и helm
> Добавляем репозиторий stable

> Устанавливаем helm чарт nginx-ingress 1.39.1 (версия 1.11.1 из ДЦ не подошла, так как использую кластер 1.16)

```shell script
# helm repo add stable https://kubernetes-charts.storage.googleapis.com
# kubectl create ns nginx-ingress
# helm upgrade --install nginx-ingress stable/nginx-ingress --wait \                                                     
--namespace=nginx-ingress \
--version=1.39.1
```

> Устанавливаем cert-manager

```shell script
# kubectl create namespace cert-manager
# helm repo add jetstack https://charts.jetstack.io
# helm repo update
# helm install \                                                                                             
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v0.15.1 \
    --set installCRDs=true
# kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
```

> Создаем ClusterIssuer, применяем

> Устанавливаем chartmuseum

```shell script
# kubectl create ns chartmuseum
# helm upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.13.0 -f chartmuseum/values.yaml
```

> Проверяем, что все ОК

```shell script
# kubectl get certificate -A                        
NAMESPACE     NAME                                READY   SECRET                              AGE
chartmuseum   chartmuseum.35.228.140.184.nip.io   True    chartmuseum.35.228.140.184.nip.io   36s
```
