# Видео Jimeng (планируется подключение)

## Описание интерфейса

Официальный API видео Jimeng в **Volcengine Visual** использует интерфейс преобразования синхронных вызовов в асинхронные задачи для генерации по тексту или первому кадру. У **Seedance в Volcengine Ark** другой шлюз и авторизация; ключ Bearer не общий.

| Шаг      | Официальный запрос                                                                        | Документация                   |
| -------- | ----------------------------------------------------------------------------------------- | ------------------------------ |
| Отправка | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [Отправить задачу](/simidoc/ru/apps/api/video/jimeng/create)   |
| Опрос    | POST на тот же хост, Action=CVSync2AsyncGetResult                                         | [Получить результат](/simidoc/ru/apps/api/video/jimeng/status) |

Раздел сохраняет официальную справку Jimeng 3.0 Pro со статусом «выводится из эксплуатации». Уточните доступные продукты и версии аккаунта в консоли Volcengine. Jimeng здесь — справка о планируемом подключении SimiRouter, без обещания публичного вызова без явной настройки.

## Авторизация и асинхронный процесс

Официально применяется HMAC-SHA256 V4 с AK/SK, Region=`cn-north-1`, Service=`cv`. Authorization не Bearer; подпись охватывает метод, путь, query, указанные headers и хеш тела.

После отправки code=10000 получите data.task\_id и опрашивайте с теми же req\_key и task\_id. Состояния\: in\_queue, generating, done, not\_found, expired. **done означает завершение обработки, но не гарантирует успех**; также проверьте code, message и video\_url. Здесь нет видеопотока в реальном времени или SSE.

## Официальные материалы

[Интерфейс Jimeng 3.0 Pro](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Официальная реализация подписи Volcengine](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).