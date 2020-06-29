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