# OpenAI Realtime API

## Описание интерфейса

Realtime обеспечивает диалог с состоянием и низкой задержкой для голоса и текста\: клиент непрерывно отправляет события, сервер — аудио, текст и вызовы инструментов. Этот API независим от [TTS](/simidoc/ru/apps/api/audio/speech), [транскрибации файлов](/simidoc/ru/apps/api/audio/transcriptions) и [перевода файлов](/simidoc/ru/apps/api/audio/translations).

| Сценарий                  | Официальное подключение                                                    | Аутентификация                                               |
| ------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------ |
| Серверный WebSocket       | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1`                  | OpenAI API Key Bearer                                        |
| WebRTC в браузере         | `/v1/realtime/calls`; сначала создайте временные учетные данные на сервере | Краткосрочный client secret; основной ключ нельзя раскрывать |
| Непрерывная транскрибация | Специальная конфигурация сеанса Realtime transcription                     | Отдельные intent/config; это не обычный диалог               |

Примеры обращаются напрямую к OpenAI. Поддержку обновления до WebSocket, передачи событий и прав модели в SimiRouter нужно проверить для выделенного канала. Обычный ответ HTTP GET не подтверждает работу реального времени. Протокол GA не использует старый заголовок `OpenAI-Beta: realtime=v1`.

## Параметры запроса

| Поле                         | Тип            | Обязателен  | Описание                                                                                                        |
| ---------------------------- | -------------- | ----------- | --------------------------------------------------------------------------------------------------------------- |
| model (query соединения)     | string         | При условии | Модель нового сеанса, например gpt-realtime-2.1; для существующего звонка используется call\_id.                |
| call\_id (query соединения)  | string         | При условии | Подключение к существующему звонку; не путать с выбором модели нового сеанса.                                   |
| session.type                 | string         | Да          | Для обновления сеанса используется realtime; для транскрибации — отдельная конфигурация.                        |
| session.instructions         | string         | Нет         | Системные инструкции по стилю и поведению.                                                                      |
| session.output\_modalities   | string\[]      | Нет         | text или audio в соответствии с текущей конфигурацией Realtime.                                                 |
| session.audio                | object         | Нет         | Формат входного/выходного аудио, голос и обнаружение речи; кодировки записи и воспроизведения должны совпадать. |
| session.tools / tool\_choice | array / string | Нет         | Определения и выбор инструментов; параметры проверяет приложение.                                               |
| event\_id                    | string         | Нет         | Клиентский идентификатор для сопоставления ошибок.                                                              |

### Основные клиентские события

| Событие                     | Назначение                                                                     |
| --------------------------- | ------------------------------------------------------------------------------ |
| `session.update`            | Обновляет конфигурацию; дождитесь session.updated с фактическими настройками.  |
| `conversation.item.create`  | Добавляет текст или другие разрешенные элементы в сеанс.                       |
| `input_audio_buffer.append` | Аудиоблок Base64; кодировка должна соответствовать session.audio.input.format. |
| `input_audio_buffer.commit` | Фиксирует буфер; само по себе не означает автоматического создания ответа.     |
| `input_audio_buffer.clear`  | Удаляет незафиксированный ввод.                                                |
| `response.create`           | Запрашивает генерацию ответа.                                                  |
| `response.cancel`           | Отменяет генерируемый ответ; проигрыватель отдельно обрабатывает буфер аудио.  |

Поток микрофона передавайте блоками с фактической частотой дискретизации. VAD определяет автоматическую фиксацию и генерацию. При прерывании очистите буфер воспроизведения или усеките элемент сеанса по официальному протоколу\: остановки динамика недостаточно.

## Ответ

| Серверные события                        | Ключевые поля и смысл                                                     |
| ---------------------------------------- | ------------------------------------------------------------------------- |
| `session.created` / `session.updated`    | Идентификатор сеанса и фактическая конфигурация.                          |
| `response.output_text.delta`             | delta содержит текстовый фрагмент.                                        |
| `response.output_audio.delta`            | delta содержит аудиофрагмент Base64, требующий декодирования.             |
| `response.output_audio_transcript.delta` | Текст озвученной речи, не замена аудио.                                   |
| `response.done`                          | response.status и usage; только completed означает нормальное завершение. |
| `error`                                  | error.type, code, message, event\_id и другие поля.                       |

Realtime использует двунаправленные события WebSocket, а не SSE `data:`. Отключение или частичное аудио не означают полного успеха; длина текста не определяет итоговую оплату.

## Примеры вызова

Укажите официальный `OPENAI_API_KEY`. Для Python выполните `python3 -m pip install websockets`; для Node.js требуется `npm install ws`; для Go требуется `go get github.com/gorilla/websocket`. Ниже отправляется один раунд **текста** для проверки полного цикла событий. Микрофон и динамик не интегрированы; ожидание ограничено 60 секундами.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import asyncio
    import json
    import os
    from websockets.asyncio.client import connect

    async def main():
        url = "wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1"
        async with connect(url, additional_headers={"Authorization":"Bearer " + os.environ["OPENAI_API_KEY"]}, open_timeout=20) as ws:
            await ws.send(json.dumps({"type":"session.update","session":{"type":"realtime","output_modalities":["text"]}}))
            await ws.send(json.dumps({"type":"conversation.item.create","item":{"type":"message","role":"user","content":[{"type":"input_text","text":"请用一句话介绍你自己。"}]}}))
            await ws.send(json.dumps({"type":"response.create"}))
            async for raw in ws:
                event = json.loads(raw)
                if event["type"] == "error":
                    raise RuntimeError(event["error"])
                if event["type"] == "response.output_text.delta":
                    print(event["delta"], end="", flush=True)
                if event["type"] == "response.done":
                    if event["response"]["status"] != "completed":
                        raise RuntimeError(event["response"])
                    print()
                    return
            raise RuntimeError("连接在 response.done 前关闭")
    asyncio.run(asyncio.wait_for(main(), 60))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const WebSocket = require("ws");
    const ws = new WebSocket("wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1", {
      headers:{Authorization:"Bearer " + process.env.OPENAI_API_KEY}
    });
    let completed = false;
    const timer = setTimeout(() => { console.error("会话超时"); process.exitCode=1; ws.terminate(); }, 60000);
    ws.on("open", () => {
      ws.send(JSON.stringify({type:"session.update",session:{type:"realtime",output_modalities:["text"]}}));
      ws.send(JSON.stringify({type:"conversation.item.create",item:{type:"message",role:"user",content:[{type:"input_text",text:"请用一句话介绍你自己。"}]}}));
      ws.send(JSON.stringify({type:"response.create"}));
    });
    ws.on("message", raw => {
      try {
        const event = JSON.parse(raw.toString());
        if(event.type === "error") throw new Error(JSON.stringify(event.error));
        if(event.type === "response.output_text.delta") process.stdout.write(event.delta);
        if(event.type === "response.done") {
          if(event.response.status !== "completed") throw new Error(JSON.stringify(event.response));
          completed = true; console.log(); ws.close();
        }
      } catch(error) { console.error(error); process.exitCode=1; ws.close(); }
    });
    ws.on("error", error => { console.error(error); process.exitCode=1; });
    ws.on("close", () => { clearTimeout(timer); if(!completed) {console.error("连接未正常完成"); process.exitCode=1;} });
    ```
  </Tab>

  <Tab value="curl">
    ```text
    cURL 单条 HTTP 命令不能完成双向实时语音会话。
    不要把 GET /v1/realtime 或 HTTP 101 握手当成完整调用。
    请使用本页 WebSocket 示例，浏览器使用官方 WebRTC 流程。
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import (
      "encoding/json"
      "fmt"
      "net/http"
      "os"
      "time"
      "github.com/gorilla/websocket"
    )
    func check(err error) {if err!=nil {panic(err)}}
    func main() {
      header:=http.Header{"Authorization":[]string{"Bearer "+os.Getenv("OPENAI_API_KEY")}}
      dialer:=websocket.Dialer{HandshakeTimeout:20*time.Second}
      ws,_,err:=dialer.Dial("wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1",header);check(err);defer ws.Close()
      check(ws.SetReadDeadline(time.Now().Add(60*time.Second)))
      check(ws.WriteJSON(map[string]any{"type":"session.update","session":map[string]any{"type":"realtime","output_modalities":[]string{"text"}}}))
      check(ws.WriteJSON(map[string]any{"type":"conversation.item.create","item":map[string]any{"type":"message","role":"user","content":[]any{map[string]any{"type":"input_text","text":"请用一句话介绍你自己。"}}}}))
      check(ws.WriteJSON(map[string]string{"type":"response.create"}))
      for {
        _,raw,err:=ws.ReadMessage();check(err)
        var event struct {Type string `json:"type"`;Delta string `json:"delta"`;Error json.RawMessage `json:"error"`;Response struct{Status string `json:"status"`} `json:"response"`}
        check(json.Unmarshal(raw,&event))
        switch event.Type {
        case "error":panic(string(event.Error))
        case "response.output_text.delta":fmt.Print(event.Delta)
        case "response.done":if event.Response.Status!="completed" {panic(event.Response.Status)};fmt.Println();return
        }
      }
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

При рукопожатии HTTP 400/401/403/404/429 относятся к параметрам, аутентификации, правам, модели и квоте. После подключения обрабатывайте error, неуспешный статус response.done и код/причину закрытия WebSocket. Обрыв или тайм-аут должны сообщаться как незавершенный результат. После переподключения восстановите состояние; не повторяйте вслепую вызванные инструменты или операции с побочными эффектами.

## Официальные материалы

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect), [Клиентские события](https\://developers.openai.com/api/reference/resources/realtime/client-events), [Серверные события](https\://developers.openai.com/api/reference/resources/realtime/server-events), [Руководство Realtime](https\://developers.openai.com/api/docs/guides/realtime).