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