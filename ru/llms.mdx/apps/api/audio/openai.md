# Формат аудио OpenAI

## Описание интерфейса

Формат аудио OpenAI включает три отдельных HTTP-маршрута с `Authorization: Bearer $SIMIROUTER_API_KEY`.

| Маршрут                         | Тип содержимого     | Ответ                                 | Документация                          |
| ------------------------------- | ------------------- | ------------------------------------- | ------------------------------------- |
| `POST /v1/audio/speech`         | JSON                | Аудиобайты; SSE при поддержке модели  | [Синтез речи](/simidoc/ru/apps/api/audio/speech)               |
| `POST /v1/audio/transcriptions` | multipart/form-data | Транскрипция JSON, текст или субтитры | [Транскрипция речи](/simidoc/ru/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | Английский текст или субтитры         | [Перевод речи](/simidoc/ru/apps/api/audio/translations)        |

Запрашиваемая `model` должна быть доступной аудиомоделью. Параметр TTS `voice`, форматы транскрипции, метки и потоки зависят от модели и не взаимозаменяемы. Файловая транскрипция не дает непрерывный сеанс микрофона; см. [Realtime](/simidoc/ru/apps/api/pending/realtime).

Это справочник формата OpenAI. Сроки поддержки моделей и параметры сверяйте с официальным API Reference маршрута. Ключи шлюза и OpenAI не взаимозаменяемы.