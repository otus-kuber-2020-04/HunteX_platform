# Выполнено ДЗ №4

## Задача "Добавление проверок Pod"

> Добавил readiness probe

> Ответы на вопросы для самопроверки:
> 1. Запущенный процесс web-сервера еще не говорит о том, что сайт будет доступен.
> 2. Информация о запущенном процессе будет важна в том случае, если ее достаточно для того, чтобы судить, что проблем нет.
>    В иных случаях лучше использовать более точные проверки

## Задача "Создание Deployment"

> Применил Deployment, убедился в корректной работе:

```shell script
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
```

> При maxUnavailable и maxSurge равным нулю, получаю ошибку

```shell script
The Deployment "web" is invalid: spec.strategy.rollingUpdate.maxUnavailable: Invalid value: intstr.IntOrString{Type:0, IntVal:0, StrVal:""}: may not be 0 when `maxSurge` is 0
```

> При maxUnavailable и maxSurge равным 100% запускаются 6 подов, позже 3 из них удаляются

> При maxUnavailable равным 0 и maxSurge равным 100% запускаются 6 подов и сразу удаляются 3

## Задача "Создание Service"

> Применил манифест:

```shell script
# kubectl get svc
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes    ClusterIP   10.96.0.1      <none>        443/TCP   18h
web-svc-cip   ClusterIP   10.111.127.2   <none>        80/TCP    15s
```

## Задача "Включение IPVS"

> Включил IPVS, пинг до сервиса идет 

## Задача "Установка MetalLB"

> Установил MetalLB

## Задача "MetalLB | Проверка конфигурации"

> Создал и применил манифест, проверил:

```shell script
# kubectl --namespace metallb-system logs pod/controller-57f648cb96-qvch8
{"branch":"HEAD","caller":"main.go:142","commit":"v0.9.3","msg":"MetalLB controller starting version 0.9.3 (commit v0.9.3, branch HEAD)","ts":"2020-06-07T13:47:52.5108847Z","version":"0.9.3"}
...
{"caller":"service.go:114","event":"ipAllocated","ip":"172.17.255.1","msg":"IP address assigned by controller","service":"default/web-svc-lb","ts":"2020-06-07T13:53:04.663230397Z"}
```

> Назначен ip 172.17.255.1
> Добавил роут, приложение доступно по адресу http://172.17.255.1/

## Задача "MetalLB" (*)

> Создаем 2 манифеста сервисов, для TCP и UDP соответственно.
> Сделать это в рамках одного сервиса не получается.
> Далее, получаем label приложения coredns, добавляем в сервисы.
> Чтобы сервисы имели идентичный IP воспользуемся подсказкой.
> P.S. важно применять манифесты сервисов в неймспейс kube-system

```shell script
# kubectl apply -f coredns/ -n kube-system
# kubectl get svc -n kube-system

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                  AGE
coredns-svc-tcp   LoadBalancer   10.99.218.58     172.17.255.3   53:32356/TCP             2s
coredns-svc-udp   LoadBalancer   10.108.232.156   172.17.255.3   53:30515/UDP             2s
kube-dns          ClusterIP      10.96.0.10       <none>         53/UDP,53/TCP,9153/TCP   19h
```

```shell script
# kubectl get svc -n kube-system
NAME              TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                  AGE
coredns-svc-tcp   LoadBalancer   10.99.218.58     172.17.255.3   53:32356/TCP             6s
coredns-svc-udp   LoadBalancer   10.108.232.156   172.17.255.3   53:30515/UDP             6s
kube-dns          ClusterIP      10.96.0.10       <none>         53/UDP,53/TCP,9153/TCP   19h
```

```shell script
# nslookup web-svc-lb.default.svc.cluster.local 172.17.255.3
Server:		172.17.255.3
Address:	172.17.255.3#53

Name:	web-svc-lb.default.svc.cluster.local
Address: 10.98.238.34
```

## Задача "Создание Ingress"

```shell script
# kubectl get svc -n ingress-nginx 
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx                        LoadBalancer   10.101.20.183   172.17.255.4   80:32070/TCP,443:30595/TCP   55s
ingress-nginx-controller             NodePort       10.106.1.229    <none>         80:30859/TCP,443:30797/TCP   2m27s
ingress-nginx-controller-admission   ClusterIP      10.97.244.213   <none>         443/TCP                      2m27s
```

```shell script
# curl 172.17.255.4
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.17.10</center>
</body>
</html>
```

## Задача "Web к Ingress"

> Создал манифест и применил
> ClusterIP для сервиса web-svc не задан

## Задача "Создание правил Ingress"

> Возникла проблема - в ingress проставляется адрес ноды

```shell script
# kubectl describe ingress/web
Name:             web
Namespace:        default
Address:          192.168.64.5
```

> Как я понимаю, в домашней работе ошибка в 2х местах:
> 1. Порт сервиса в ингрессе должен быть 80, а не 8080.
> 2. LB_IP должен соответствовать ip ноды, чтобы иметь возможность достучаться до него снаружи.

## Задача на дашбоард (*)

> Использовал уже созданный сервис
> Также настроил два реврайта - реврайт на / и реврайт без dashboard
> Приложил файл test.sh для быстрого выполнения шагов

## Задача на Canary (*)

TODO
