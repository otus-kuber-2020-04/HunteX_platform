# ДЦ "Шаблонизация манифестов"

## Подготовка

> Создаем managed kubernetes кластер в GCP
> Устанавливаем gcloud и helm
> Добавляем репозиторий stable

## nginx-ingress

> Устанавливаем helm чарт nginx-ingress 1.39.1 (версия 1.11.1 из ДЦ не подошла, так как использую кластер 1.16)

```shell script
# helm repo add stable https://kubernetes-charts.storage.googleapis.com
# kubectl create ns nginx-ingress
# helm upgrade --install nginx-ingress stable/nginx-ingress --wait \                                                     
--namespace=nginx-ingress \
--version=1.39.1
```

## cert-manager

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

## chartmuseum

> Устанавливаем chartmuseum

```shell script
# kubectl create ns chartmuseum
# helm upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.13.0 -f chartmuseum/values.yaml
```

> Проверяем, что все ОК

```shell script
# kubectl get certificate -A                        
NAMESPACE     NAME                                READY   SECRET                              AGE
chartmuseum   chartmuseum.35.228.112.229.nip.io   True    chartmuseum.35.228.112.229.nip.io   36s
```

## chartmuseum (*)

> Создаем чарт

```shell script
# helm create my-super-chart
```

> Оказывается, что сначала необходимо выключить параметр DISABLE_API и передеплоить chartmeseum
> Собираем его и отправляем в chartmuseum

```shell script
# helm package .
# curl --data-binary "@my-super-chart-0.1.0.tgz" https://chartmuseum.35.228.112.229.nip.io/api/charts
```

> Добавляем чарт-репозиторий

```shell script
# helm repo add chartmuseum https://chartmuseum.35.228.112.229.nip.io
```

> Ищем чарт

```shell script
# helm search repo my-super-chart
NAME                      	CHART VERSION	APP VERSION	DESCRIPTION                
chartmuseum/my-super-chart	0.1.0        	1.16.0     	A Helm chart for Kubernetes
```

## harbor

> Добавляем чарт-репозиторий

```shell script
# helm repo add harbor https://helm.goharbor.io
```

> Создаем values.yaml для harbor
> Устанавливаем harbor (во избежание проблем, устанавливаем последнюю версию чарта 1.4.0)

```shell script
# kubectl create ns harbor
# helm upgrade --install harbor harbor/harbor --wait --namespace=harbor --version=1.4.0 -f harbor/values.yaml
```

## helmfile (*)

> Установил helmfile
> Также нужно установить helm-diff

```shell script
# helm plugin install https://github.com/databus23/helm-diff
```

> Не добавлял ClusterIssuer
> Запускал helmfile apply в корне директории helmfile/
> Так как не понял как задавать файл

## Создаем свой helm chart

> Создал frontend чарт, вынес туда конфигурацию, создал Ingress
> Шаблонизировал меняющиеся параметры
> Добавил этот чарт как зависимость к родительскому чарту

## Создаем свой helm chart (*)

> Подключил community chart Redis

## Проверка

> Добавляем harbor

```shell script
# helm repo add templating https://harbor.35.228.112.229.nip.io/chartrepo/library
# helm repo update
```

> Устанавливаем плагин helm-push для публикации чартов в Harbor

```shell script
# helm plugin install https://github.com/chartmuseum/helm-push
```

> Обновляем зависимости и пакуем

```shell script
# helm dep update hipster-shop
# helm package frontend/ -d frontend
# helm package hipster-shop/ -d hipster-shop
```

> Делаем push

```shell script
# helm push --username admin --password Harbor12345 ./frontend/ templating
# helm push --username admin --password Harbor12345 ./hipster-shop/ templating
```

> Проверяем установки, удалив прошлый релиз

```shell script
# helm uninstall -n hipster-shop hipster-shop
# helm upgrade --install hipster-shop templating/hipster-shop --namespace hipster-shop
```

## Kubecfg

> Вынес сущности из общего файла в отдельные манифесты
> Установил kubecfg
> Добавил services.jsonnet

## Kapitan (Задание со *)

> Инициализировал директорию

```shell script
docker run -t --rm -v $(pwd):/src:delegated deepmind/kapitan init --directory jsonnet
```

> Вынес adservice и скомпилировал (простая реализация через copy)

```shell script
docker run -t --rm -v $(pwd):/src:delegated deepmind/kapitan compile
```
