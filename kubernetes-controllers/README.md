# Выполнено ДЗ №2

## Задача на ReplicaSet

> Создаем кластер в kind из 6 нод - 3х мастеров и 3х воркеров

```shell script
# kubectl get nodes
NAME                  STATUS   ROLES    AGE     VERSION
kind-control-plane    Ready    master   2m38s   v1.18.2
kind-control-plane2   Ready    master   2m9s    v1.18.2
kind-control-plane3   Ready    master   80s     v1.18.2
kind-worker           Ready    <none>   56s     v1.18.2
kind-worker2          Ready    <none>   55s     v1.18.2
kind-worker3          Ready    <none>   54s     v1.18.2
```

> При попытке добавить в кластер ReplicaSet, получил следующую ошибку:

```shell script
# kubectl apply -f frontend-replicaset.yaml 
error: error validating "frontend-replicaset.yaml": error validating data: ValidationError(ReplicaSet.spec): missing required field "selector" in io.k8s.api.apps.v1.ReplicaSetSpec; if you choose to ignore these errors, turn validation off with --validate=false
```

> Следовательно, необходимо добавить поле `selector`. Также добавим environment переменные:

```shell script
# kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
frontend   1         1         1       11s

# kubectl get pods -l app=frontend
NAME             READY   STATUS    RESTARTS   AGE
frontend-6gbbv   1/1     Running   0          57s
```

> Повышаем количество реплик:

```shell script
# kubectl scale replicaset frontend --replicas=3
replicaset.apps/frontend scaled
```

> Проверяем:

```shell script
# kubectl get rs frontend
NAME       DESIRED   CURRENT   READY   AGE
frontend   3         3         3       2m46s
```

> Удаляем и проверяем:

```shell script
kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w
NAME             READY   STATUS    RESTARTS   AGE
frontend-6gbbv   1/1     Running   0          3m39s
frontend-7r9m9   1/1     Running   0          114s
frontend-qg2nt   1/1     Running   0          114s
frontend-6gbbv   1/1     Terminating   0          3m39s
frontend-7r9m9   1/1     Terminating   0          114s
frontend-qg2nt   1/1     Terminating   0          114s
frontend-mrkhw   0/1     Pending       0          0s
frontend-txchv   0/1     Pending       0          0s
frontend-txchv   0/1     Pending       0          0s
frontend-mrkhw   0/1     Pending       0          0s
frontend-5cv6n   0/1     Pending       0          0s
frontend-txchv   0/1     ContainerCreating   0          0s
frontend-5cv6n   0/1     Pending             0          0s
frontend-mrkhw   0/1     ContainerCreating   0          0s
frontend-5cv6n   0/1     ContainerCreating   0          0s
frontend-6gbbv   0/1     Terminating         0          3m40s
frontend-mrkhw   1/1     Running             0          1s
frontend-qg2nt   0/1     Terminating         0          115s
frontend-7r9m9   0/1     Terminating         0          115s
frontend-txchv   1/1     Running             0          1s
frontend-5cv6n   1/1     Running             0          2s
frontend-6gbbv   0/1     Terminating         0          3m49s
frontend-6gbbv   0/1     Terminating         0          3m49s
frontend-7r9m9   0/1     Terminating         0          2m4s
frontend-7r9m9   0/1     Terminating         0          2m4s
frontend-qg2nt   0/1     Terminating         0          2m6s
frontend-qg2nt   0/1     Terminating         0          2m6s
```

> Повторно применяем манифест:

```shell script
# kubectl apply -f frontend-replicaset.yaml                               
replicaset.apps/frontend configured
```

> Убедимся, что количество реплик вернулось к 1

```shell script
# kubectl get rs frontend
NAME       DESIRED   CURRENT   READY   AGE
frontend   1         1         1       11m
```

> Меняем манифест, чтобы было 3 реплики, применяем

## Задача на обновление ReplicaSet

> Запушил в dockerhub huntex/frontend:2
> Применил измененный манифест - изменения только в ReplicaSet, изменений в подах нет.

```shell script
# kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}'
huntex/frontend:2%

# kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'
huntex/frontend:1 huntex/frontend:1 huntex/frontend:1% 
```

> Удаляем запущенные поды:

```shell script
# kubectl delete pods -l app=frontend
pod "frontend-gt4mb" deleted
pod "frontend-hsmv8" deleted
pod "frontend-txchv" deleted
```

> Проверяем версию созданных ReplicaSet подов:

```shell script
# kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'
huntex/frontend:2 huntex/frontend:2 huntex/frontend:2% 
```

> После пересоздания подов они имеют новую версию приложения. В лекции говорили про этот момент, что контроллер ReplicaSet не следит за такими изменениями, поэтому, пришлось явно удалить поды, чтобы они создались уже на основе обновленного ReplicaSet.

## Задача на Deployment

> Подготовил образы, запушил в dockerhub
> Создаем валидный манифест paymentservice-replicaset.yaml
> Создаем валидный манифест paymentservice-deployment.yaml
> Применяем его, проверяем, что создался он, репликасет и поды:

```shell script
# kubectl apply -f paymentservice-deployment.yaml 
deployment.apps/paymentservice created

# kubectl get po -l app=paymentservice
NAME                             READY   STATUS    RESTARTS   AGE
paymentservice-f75695b78-766nf   1/1     Running   0          109s
paymentservice-f75695b78-j9gr6   1/1     Running   0          109s
paymentservice-f75695b78-z7jmq   1/1     Running   0          109s

# kubectl get rs
NAME                       DESIRED   CURRENT   READY   AGE
paymentservice-f75695b78   3         3         3       5m8s
```

> Обновляем версию деплоймента на v0.0.2 и применяем

```shell script
# kubectl apply -f paymentservice-deployment.yaml | kubectl get pods -l app=paymentservice
-w
```

> Создался еще один ReplicaSet и поды сменили версию на новую.
> Посмотрим историю:

```shell script
# kubectl rollout history deployment paymentservice
deployment.apps/paymentservice 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

> Откатимся и проверим версию образа

```shell script
# kubectl rollout undo deployment paymentservice --to-revision=1
# kubectl get pods -l app=paymentservice -o=jsonpath='{.items[0:3].spec.containers[0].image}'
huntex/paymentservice:v0.0.1 huntex/paymentservice:v0.0.1 huntex/paymentservice:v0.0.1%
```

## Задача на Deployment (*)

> Используем параметры `maxSurge` и `maxUnavailable`

## Задача на Probes

> Создадим деплоймент, добавим readinessProbe, применим и проверяем:

```shell script
# kubectl get po                           
NAME                        READY   STATUS    RESTARTS   AGE
frontend-74d8759784-4k6k7   1/1     Running   0          24s
frontend-74d8759784-jb5k5   1/1     Running   0          24s
frontend-74d8759784-z4qng   1/1     Running   0          24s
```

> Укажем некорректный путь и новую версию, применим

```shell script
# kubectl get po   
NAME                        READY   STATUS    RESTARTS   AGE
frontend-59df9b948c-wtw8j   0/1     Running   0          116s
frontend-74d8759784-4k6k7   1/1     Running   0          21m
frontend-74d8759784-jb5k5   1/1     Running   0          21m
frontend-74d8759784-z4qng   1/1     Running   0          21m

# kubectl decribe pod frontend-59df9b948c-wtw8j
Warning  Unhealthy  32s (x2 over 42s)     kubelet, kind-worker  Readiness probe failed: HTTP probe failed with statuscode: 404
```

> Проверяем статус

```shell script
# kubectl rollout status deployment/frontend
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
error: deployment "frontend" exceeded its progress deadline

# kubectl rollout undo deployment/frontend
```

## Задача на DaemonSet (*)

> Нашел готовый здесь https://github.com/coreos/kube-prometheus/blob/master/manifests/node-exporter-daemonset.yaml
> Пришлось удалить namespace и serviceAccountName, по-хорошему, их конечно нужно создать, но для тестового запуска можно и без них:

```shell script
# curl localhost:9100/metrics
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
go_gc_duration_seconds_count 0
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 6
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.12.5"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 902344
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
```

## Задача на DaemonSet (**)

> В моем случае поды сразу запустились, в том числе и на мастерах.

```shell script
# kubectl get pods -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP           NODE                  NOMINATED NODE   READINESS GATES
node-exporter-45k84   2/2     Running   0          10m   172.21.0.2   kind-worker2          <none>           <none>
node-exporter-8kh5n   2/2     Running   0          10m   172.21.0.5   kind-control-plane2   <none>           <none>
node-exporter-dz4sh   2/2     Running   0          10m   172.21.0.3   kind-worker           <none>           <none>
node-exporter-fq66z   2/2     Running   0          10m   172.21.0.6   kind-control-plane    <none>           <none>
node-exporter-gpggc   2/2     Running   0          10m   172.21.0.8   kind-control-plane3   <none>           <none>
node-exporter-nzhs6   2/2     Running   0          10m   172.21.0.4   kind-worker3          <none>           <none>
```

> Так что пойдем от обратного - судя по документации 
> https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

```yaml
      tolerations:
      # this toleration is to have the daemonset runnable on master nodes
      # remove it if your masters can't run pods
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
```

> Необходимо удалить эти строки, чтобы все заработало.
> P.S. удаление этих строчек не помогает, в официальной документации не нашел этого, гугление помогло
> https://docs.platform9.com/kubernetes/disallowing-workloads-on-kubernetes-master-nodes/
> Необходимо также добавить дополнительные значения в tolerations, либо, как я понял, можно просто задать все в key
