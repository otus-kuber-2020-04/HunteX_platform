# ДЗ "Custom Resource Definitions. Operators."

## Подготовка

> Создаем Custom Resource и Custom Resource Definition
> Поправил apiVersion у crd, так как предыдущая была deprecated
> Применил их в кластер
> Добавил валидацию, применил изменения в кластер

## Задание по CRD

> Добавил в схему required поля

## MySQL контроллер

> Добавил шаблоны и контроллер
> Запустил

```shell script
# kopf run mysql-operator.py
[2020-06-29 20:55:42,253] kopf.reactor.activit [INFO    ] Initial authentication has been initiated.
[2020-06-29 20:55:42,265] kopf.activities.auth [INFO    ] Activity 'login_via_pykube' succeeded.
[2020-06-29 20:55:42,274] kopf.activities.auth [INFO    ] Activity 'login_via_client' succeeded.
[2020-06-29 20:55:42,274] kopf.reactor.activit [INFO    ] Initial authentication has finished.
[2020-06-29 20:55:42,310] kopf.engines.peering [WARNING ] Default peering object not found, falling back to the standalone mode.
mysql-operator.py:11: YAMLLoadWarning: calling yaml.load() without Loader=... is deprecated, as the default Loader is unsafe. Please read https://msg.pyyaml.org/load for full details.
  json_manifest = yaml.load(yaml_manifest)
[2020-06-29 20:55:42,533] kopf.objects         [INFO    ] [default/mysql-instance] Handler 'mysql_on_create' succeeded.
[2020-06-29 20:55:42,534] kopf.objects         [INFO    ] [default/mysql-instance] All handlers succeeded for creation.
```

> Ответ на вопрос, почему объект создался:
> Потому что это объект обработчика (handler object), а не объект, ранее созданный применением CR
> Остановил mysql-operator.py, удалил созданные им ресурсы
> Доработал mysql-operator.py
> Доработал PV и PVC, так как не получалось сделать bound
> Удалил инстанс

```shell script
# kubectl delete mysqls.otus.homework mysql-instance
mysql.otus.homework "mysql-instance" deleted
```

> Проверил, что успешно отработала джоба бэкапа

```shell script
# kubectl get jobs.batch
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           1s         10s
```

> Создал инстанс заново, проверяем работу джобы восстановления

```shell script
# kubectl exec -it mysql-instance-f5b97ffff-7lbb4 -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
```

> Собрал и запушил докер образ в https://hub.docker.com/r/huntex/operator
> Добавил в deploy сущности для запуска оператора внутри пода
> Проверил, что все работает

> Вывод #1

```shell script
# kubectl get jobs                                      
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           1s         89s
restore-mysql-instance-job   1/1           3m11s      3m21s
```

> Вывод #2

```shell script
# export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
# kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
```