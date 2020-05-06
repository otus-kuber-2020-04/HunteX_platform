# HunteX_platform
HunteX Platform repository

# Задание 1: Разобраться почему поды в неймспейсе kube-system восстановились после удаления
В kubernetes запущен kube-scheduler и он следит состоянием кластера, которое хранится в etcd.
Одна из его задач - это приводить реальное состояние кластера к тому состоянию, что хранится в etcd.
И, в нашем случае, когда поды удалены командой `kubectl delete pod --all -n kube-system` планировщик отдает команду на их запуск.
Далее, kubelet на выбранной планировщиком ноде запускает поды.
Общение между kube-scheduler и kubelet производится через kube-apiserver.
В итоге удаленные поды должны восстановиться (через создание).

# Задание 2
```
docker build -t web:1 .
docker tag web:1 huntex/web:1
docker push huntex/web:1
docker run -d -p 8000:8000 -v $(pwd):/app huntex/web:1
```
