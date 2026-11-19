# Видео Seedance

## Описание интерфейса

Seedance создаёт видео по тексту и разрешённым моделью образцам изображения, видео и аудио. Официальный процесс Ark\: создать асинхронную задачу, проверить состояние, скачать после успеха.

| Операция | Официальный путь                              | Документация                 |
| -------- | --------------------------------------------- | ---------------------------- |
| Создание | `POST /api/v3/contents/generations/tasks`     | [Создать задачу](/simidoc/ru/apps/api/video/seedance/create)   |
| Опрос    | `GET /api/v3/contents/generations/tasks/{id}` | [Проверить задачу](/simidoc/ru/apps/api/video/seedance/status) |

Официальный базовый адрес `https://ark.cn-beijing.volces.com`, с `ARK_API_KEY`, авторизация Bearer. `/v1/video/generations` — совместимый путь шлюза, не официальный адрес Ark. Используйте только при явно заданном соответствии канала; не преобразуйте id/status автоматически в формат другого поставщика.

Состояния `queued → running → succeeded`; неуспешные конечные состояния — failed, expired, cancelled. Это не SSE и не Realtime. Звук, материалы, длительность и разрешение зависят от версии модели.

## Официальные материалы

[Создать видеозадачу](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Проверить задачу](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh), [Видеоруководство](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).