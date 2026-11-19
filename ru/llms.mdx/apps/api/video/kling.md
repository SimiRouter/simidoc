# Видео Kling

## Описание интерфейса

Новый официальный API Kling использует пути функции/модели, settings/options и общий опрос\:

| Операция            | Текущий официальный интерфейс                     | Документация                                         |
| ------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| Текст в видео       | `POST /text-to-video/kling-3.0`                   | [Создание](/simidoc/ru/apps/api/video/kling/text-create) / [Опрос](/simidoc/ru/apps/api/video/kling/text-status)   |
| Изображение в видео | `POST /image-to-video/kling-3.0`                  | [Создание](/simidoc/ru/apps/api/video/kling/image-create) / [Опрос](/simidoc/ru/apps/api/video/kling/image-status) |
| Опрос               | `GET /tasks?task_ids=...` или external\_task\_ids | Общий опрос задач                                    |

Примеры обращаются напрямую к `https://api-singapore.klingai.com` с официальным ключом API Kling через Bearer. Старые AK/SK + HS256 JWT подходят только старому стандарту; ключ SimiRouter или отдельный SecretKey не являются ключом Kling.

## Не смешивайте протоколы

Старый `/v1/videos/text2video`, `/v1/videos/image2video` использует model\_name, task\_id, task\_status и succeed; новый — модель в маршруте, data.id, status и succeeded. Для старых endpoint остаётся legacy-справка, но добавлять их поля в новые запросы нельзя. SimiRouter `/kling/...` — соответствие шлюза, требующее проверки версии канала; добавления префикса к новому официальному пути недостаточно.

Генерация асинхронна, не SSE. После создания опрашивайте или получайте callback; элементы video в outputs используйте только при успешном конечном состоянии.

## Официальные материалы

[Текст в видео Kling](https\://kling.ai/document-api/apiReference/model/textToVideo), [Изображение в видео](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Аутентификация](https\://kling.ai/document-api/api/get-started/authentication).