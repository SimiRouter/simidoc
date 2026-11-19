# Music (unsupported)

This section documents Google Lyria’s public generation protocol. SimiRouter has not yet opened music capabilities; all examples connect directly to the Google AI Studio Gemini API using `https://generativelanguage.googleapis.com` and a Google API key. Vertex AI requires a separate protocol that is not verified on this page; do not substitute its address directly.

## Overview

| Capability               | Input                                           | Output                                                        | Status of this section |
| ------------------------ | ----------------------------------------------- | ------------------------------------------------------------- | ---------------------- |
| Generate a music clip    | Text description or an image                    | About 30 seconds of audio, MP3 by default                     | Official API reference |
| Generate a complete song | Prompt with verse and chorus descriptions       | A song of several minutes, possibly with lyrics and structure | Official API reference |
| Realtime performance     | Continuously sent prompts and playback controls | Continuous PCM audio chunks                                   | Official API reference |

## Core concepts

* **Clip vs. song**\: clips are fixed at 30 seconds and suit previews and loops; songs take their length and structure from the prompt, so duration is not an exact guarantee.
* **Realtime session**\: a bidirectional WebSocket that accepts continuous prompts and PLAY or PAUSE controls while connected; it is not a one-shot request with a stream switch.
* **Audio format**\: MP3 by default, WAV on request; the realtime endpoint returns raw PCM chunks that the application must buffer and wrap itself.
* **Keys and addresses**\: examples on this page use only the Google AI Studio Gemini API address and a Google API key; SimiRouter does not proxy music models, and Vertex AI’s separate protocol is not verified here.

Duration caps, sample rates, and bit rates depend on the model; see the parameter tables in [Lyria](/simidoc/en/apps/api/music/lyria) and [RealTime](/simidoc/en/apps/api/music/realtime).

## Endpoint overview

| Mode                      | Official protocol           | Capability                                                      | Documentation                     |
| ------------------------- | --------------------------- | --------------------------------------------------------------- | --------------------------------- |
| One-shot music generation | `POST /v1beta/interactions` | Generate clips or complete songs from text or images            | [Lyria music generation](/simidoc/en/apps/api/music/lyria) |
| Realtime music            | Bidirectional WebSocket     | Continuously generate and dynamically adjust instrumental audio | [Lyria RealTime](/simidoc/en/apps/api/music/realtime)      |

Lyria Clip generates 30-second clips; Lyria 3.5 targets more complete songs. RealTime is experimental and uses a persistent connection, not the Interactions stream switch. Music models do not read ordinary text aloud; for TTS, use [Audio](/simidoc/en/apps/api/audio).

## Simulated call

Official one-shot Google generation uses Interactions, with the request describing style and structure\:

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

The audio in the response is Base64, not a download URL\:

```json
{
  "steps": [
    {
      "type": "model_output",
      "content": [
        { "type": "text", "text": "[Instrumental]" },
        { "type": "audio", "data": "<Base64音频>" }
      ]
    }
  ]
}
```

Audio and text items can interleave, so walk `content[]` by `type`; taking only the last item drops lyrics or structural notes.

## Authentication and rights

Google’s official Interactions API uses `x-goog-api-key: $GEMINI_API_KEY`; realtime connections use the official SDK or WebSocket protocol. Generated content remains subject to Google’s terms, copyright, and voice-authorization requirements. Model availability, regions, and quotas depend on the Google account.

## Official reference

[Google music generation](https\://ai.google.dev/gemini-api/docs/music-generation), [Realtime music](https\://ai.google.dev/gemini-api/docs/realtime-music-generation).