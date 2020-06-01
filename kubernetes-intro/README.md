# Выполнено ДЗ №1

 - [+] Основное ДЗ

## В процессе сделано:
 - Прочитана документация, сделан следующий вывод:

> * В kubernetes запущен kube-controller-manager и он следит состоянием кластера, которое хранится в etcd.
> * Одна из его задач - это приводить реальное состояние кластера к тому состоянию, что хранится в etcd.
> * И, в нашем случае, когда поды удалены командой `kubectl delete pod --all -n kube-system` kube-controller-manager отдает команду на их запуск.
> * В случае с coredns это происходит из-за ресурсов Deployment и ReplicaSet
```
➜  ~ kubectl get deployments -n kube-system   
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   2/2     2            2           3h47m
➜  ~ kubectl get replicaset -n kube-system
NAME                 DESIRED   CURRENT   READY   AGE
coredns-66bff467f8   2         2         2       3h47m
```
> * В случае с kube-apiserver, судя по документации, это реализовано иначе https://kubernetes.io/docs/tasks/administer-cluster/guaranteed-scheduling-critical-addon-pods/
> * Далее, kubelet на выбранной планировщиком ноде запускает поды.
> * Общение между kube-controller-manager и kubelet производится через kube-apiserver.
> * В итоге удаленные поды должны восстановиться (через создание).

# Выполнено ДЗ №2

 - [+] Основное ДЗ

 - реализован Docker-образ на основе nginx
 - опубликован на dockerhub как huntex/web:1

## Как запустить проект:
 - Выполнить команду `docker run -d -p 8000:8000 -v $(pwd):/app huntex/web:1`
 - Выполнить команду `kubectl port-forward --address 0.0.0.0 pod/web 8000:8000`

# Выполнено ДЗ №3

 - [+] Задание со *

 - собран Docker-образ hipster-frontend
 - опубликован на dockerhub как huntex/frontend:1

> Судя по логам пода
```
panic: environment variable "PRODUCT_CATALOG_SERVICE_ADDR" not set
```
> необходимо задать эту и другие переменные, судя по имени, это адреса других сервисов в этом проекте из микросервисов

## Как запустить проект:
 - Выполнить команду `kubectl apply -f frontend-pod-healthy.yaml`
 - Выполнить команду `kubectl get po`

## Как проверить работоспособность:
 - Убедиться, что Pod в статусе "Running"

```
➜  kubernetes-intro git:(kubernetes-prepare) ✗ kubectl get po
NAME       READY   STATUS    RESTARTS   AGE
frontend   1/1     Running   0          6s
```

## PR checklist:
 - [+] Выставлен label с темой домашнего задания
