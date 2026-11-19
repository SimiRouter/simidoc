# OpenAI audio format

## Endpoint overview

The OpenAI audio format has three separate HTTP endpoints, all using `Authorization: Bearer $SIMIROUTER_API_KEY`.

| Endpoint                        | Content type        | Response                                     | Documentation                            |
| ------------------------------- | ------------------- | -------------------------------------------- | ---------------------------------------- |
| `POST /v1/audio/speech`         | JSON                | Audio bytes; SSE when supported by the model | [Speech synthesis](/simidoc/en/apps/api/audio/speech)             |
| `POST /v1/audio/transcriptions` | multipart/form-data | Transcription JSON, text, or subtitles       | [Speech transcription](/simidoc/en/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | English translation text or subtitles        | [Speech translation](/simidoc/en/apps/api/audio/translations)     |

Request `model` must be an audio model available to the account. TTS `voice`, transcription output formats, timestamps, and streaming capabilities vary by model and are not interchangeable. File transcription does not provide a continuous microphone session; see [Realtime](/simidoc/en/apps/api/pending/realtime).

This page references the OpenAI API format. Model lifecycle and vendor parameters follow each endpoint’s official API Reference. Gateway keys and official OpenAI keys are not interchangeable.