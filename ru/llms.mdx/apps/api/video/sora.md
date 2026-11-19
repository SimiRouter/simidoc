# Видео Sora (официальный интерфейс закрыт)

**Официальные Sora 2 и Videos API OpenAI закрыты 24 сентября 2026 года.** Ниже лишь архив структуры, не рабочая инструкция. Если SimiRouter предлагает одноимённую модель или стороннюю совместимую реализацию, отдельно проверьте источник, возможности и протокол; нельзя называть это прямым официальным OpenAI API.

## Описание интерфейса

| Операция         | Прежняя официальная точка           | Справочник            |
| ---------------- | ----------------------------------- | --------------------- |
| Создать задачу   | `POST /v1/videos`                   | [Создание](/simidoc/ru/apps/api/video/sora/create)  |
| Проверить задачу | `GET /v1/videos/{video_id}`         | [Опрос](/simidoc/ru/apps/api/video/sora/status)     |
| Скачать видео    | `GET /v1/videos/{video_id}/content` | [Значение](/simidoc/ru/apps/api/video/sora/content) |

Прежняя генерация была асинхронной\: queued/in\_progress переходили в completed или failed, без обычного потокового выхода. Официальное уведомление не предлагает прямой заменяющий API. Для других возможностей выберите поставщика в [категории видео](/simidoc/ru/apps/api/video), без автоматической замены.

## Официальные материалы

[Уведомление OpenAI о закрытии](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create).