# Musique en temps réel Lyria RealTime

Les pages ci-dessous suivent l’API officielle Google. SimiRouter n’a pas encore ouvert cette capacité ; tous les exemples se connectent directement à l’API Gemini de Google AI Studio avec `https://generativelanguage.googleapis.com` et une clé API Google. Vertex AI exige un protocole distinct, non vérifié sur cette page ; ne remplacez pas directement l’adresse.

## Description de l’interface

Connectez-vous à `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY` avec le modèle `models/lyria-realtime-exp`. C’est un WebSocket bidirectionnel avec état, pas un HTTP POST, un SSE ou Lyria 3.5 Interactions.

## Paramètres de requête

Un seul événement de premier niveau par message ; après connexion, envoyez setup et attendez setupComplete avant les consignes musicales et commandes de lecture.

| Champ                                                         | Type             | Obligatoire | Description                                                                             |
| ------------------------------------------------------------- | ---------------- | ----------- | --------------------------------------------------------------------------------------- |
| setup.model                                                   | string           | Oui         | models/lyria-realtime-exp, uniquement dans le premier message de connexion.             |
| clientContent.weightedPrompts                                 | object\[]        | Oui         | Au moins un couple text/weight ; les poids ne peuvent pas être tous nuls.               |
| musicGenerationConfig.bpm                                     | integer          | Non         | 60–200 ; après modification, RESET\_CONTEXT ou reprise de lecture nécessaire.           |
| musicGenerationConfig.guidance                                | number           | Non         | 0–6, défaut 4.                                                                          |
| musicGenerationConfig.density / brightness                    | number           | Non         | 0–1, densité de notes et brillance.                                                     |
| musicGenerationConfig.temperature / topK                      | number / integer | Non         | 0–3 / 1–1000.                                                                           |
| musicGenerationConfig.seed                                    | integer          | Non         | Graine aléatoire.                                                                       |
| musicGenerationConfig.scale                                   | string           | Non         | Énumération Scale officielle ; changer de gamme exige une réinitialisation du contexte. |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | Non         | Contrôle des basses et percussions.                                                     |
| musicGenerationConfig.musicGenerationMode                     | string           | Non         | QUALITY, DIVERSITY ou modes expérimentaux pris en charge.                               |
| playbackControl                                               | string           | Oui         | PLAY, PAUSE, STOP, RESET\_CONTEXT.                                                      |

## Valeur de retour

* `setupComplete` \: les messages suivants peuvent être envoyés.
* `serverContent.audioChunks[].data` \: blocs audio en Base64 dans le JSON ; concaténez les échantillons bruts après décodage.
* `audioChunks[].mimeType` \: type audio ; ne supposez pas MP3/WAV.
* `filteredPrompt` \: raison du filtrage de la consigne ; `warning` est un avertissement et n’arrête pas forcément la session.

Le format fixe est du PCM stéréo 16 bits à 48 kHz ; `audioChunks[].mimeType` identifie le type audio de la réponse et ne modifie pas la fréquence d’échantillonnage. La génération peut être plus rapide que la lecture \: l’application doit mettre en tampon, éviter les craquements et gérer la lecture. L’exemple enregistre `music.pcm`, sans le faire passer pour un WAV avec en-tête.

## Exemples de code

Définissez la variable Google `GEMINI_API_KEY`. Python nécessite `websockets`, Node.js nécessite `ws` et Go nécessite `github.com/gorilla/websocket`. Les exemples se connectent au maximum 30 secondes et peuvent entraîner des frais d’inférence ; ils n’intègrent ni microphone ni périphérique de lecture.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import asyncio
    import base64
    import json
    import os
    from pathlib import Path
    from websockets.asyncio.client import connect

    received_chunks = 0

    async def main():
        global received_chunks
        if not os.environ.get("GEMINI_API_KEY"):
            raise RuntimeError("请设置 GEMINI_API_KEY")
        if Path("music.pcm").exists():
            raise RuntimeError("music.pcm 已存在，请先选择新的输出文件名")
        url = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=" + os.environ["GEMINI_API_KEY"]
        async with connect(url, open_timeout=20, max_size=None) as ws:
            await ws.send(json.dumps({"setup":{"model":"models/lyria-realtime-exp"}}))
            while True:
                event = json.loads(await ws.recv())
                if "error" in event:
                    raise RuntimeError(event["error"])
                if "setupComplete" in event:
                    break
            await ws.send(json.dumps({"clientContent":{"weightedPrompts":[{"text":"minimal techno","weight":1.0}]}}))
            await ws.send(json.dumps({"musicGenerationConfig":{"bpm":90}}))
            await ws.send(json.dumps({"playbackControl":"PLAY"}))
            with Path("music.pcm").open("xb") as output:
                while True:
                    event = json.loads(await ws.recv())
                    if "error" in event:
                        raise RuntimeError(event["error"])
                    if "filteredPrompt" in event:
                        raise RuntimeError(event["filteredPrompt"])
                    for chunk in event.get("serverContent",{}).get("audioChunks",[]):
                        print("MIME:", chunk.get("mimeType"))
                        decoded = base64.b64decode(chunk["data"], validate=True)
                        if decoded:
                            output.write(decoded)
                            received_chunks += 1

    try:
        asyncio.run(asyncio.wait_for(main(), 30))
    except TimeoutError:
        if received_chunks == 0:
            raise RuntimeError("采样窗口内未收到音频，会话未成功")
        print(f"30 秒采样结束，已保存 {received_chunks} 个音频块；这不是模型自然终态。")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const WebSocket = require("ws");
    const { createWriteStream, existsSync } = require("node:fs");
    if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
    if (existsSync("music.pcm")) throw new Error("music.pcm 已存在，请先选择新的输出文件名");
    const output = createWriteStream("music.pcm", {flags:"wx"});
    let receivedChunks = 0;
    const ws = new WebSocket("wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=" + process.env.GEMINI_API_KEY);
    let ready = false;
    const timer = setTimeout(() => { ws.close(); output.end(); }, 30000);
    ws.on("open", () => ws.send(JSON.stringify({setup:{model:"models/lyria-realtime-exp"}})));
    ws.on("message", raw => {
      try {
        const event = JSON.parse(raw.toString());
        if (event.error || event.filteredPrompt) throw new Error(JSON.stringify(event.error || event.filteredPrompt));
        if (event.setupComplete && !ready) {
          ready = true;
          ws.send(JSON.stringify({clientContent:{weightedPrompts:[{text:"minimal techno",weight:1}]}}));
          ws.send(JSON.stringify({musicGenerationConfig:{bpm:90}}));
          ws.send(JSON.stringify({playbackControl:"PLAY"}));
        }
        for (const chunk of event.serverContent?.audioChunks || []) {
          console.log("MIME:", chunk.mimeType);
          const data = Buffer.from(chunk.data,"base64");
          if (data.length) { output.write(data); receivedChunks++; }
        }
      } catch (error) { console.error(error); process.exitCode=1; ws.close(); }
    });
    ws.on("error", error => { console.error(error); process.exitCode=1; });
    ws.on("close", () => {
      clearTimeout(timer); output.end();
      if (!receivedChunks) { console.error("会话关闭前未收到音频"); process.exitCode=1; }
    });
    output.on("error", error => { console.error(error); process.exitCode=1; ws.close(); });
    ```
  </Tab>

  <Tab value="curl">
    ```text
    cURL 命令行不能完成持续的双向 WebSocket 音乐会话。
    请使用本页 Python、Node.js 或 Go 示例，不要用普通 POST 伪造音乐流。
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import (
      "encoding/base64"
      "encoding/json"
      "fmt"
      "net/url"
      "os"
      "time"
      "github.com/gorilla/websocket"
    )
    func check(err error) { if err!=nil {panic(err)} }
    func main() {
      if os.Getenv("GEMINI_API_KEY")=="" {panic("请设置 GEMINI_API_KEY")}
      endpoint := "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key="+url.QueryEscape(os.Getenv("GEMINI_API_KEY"))
      dialer:=websocket.Dialer{HandshakeTimeout:20*time.Second}
      ws,_,err:=dialer.Dial(endpoint,nil);check(err);defer ws.Close()
      check(ws.SetReadDeadline(time.Now().Add(30*time.Second)))
      check(ws.WriteJSON(map[string]any{"setup":map[string]string{"model":"models/lyria-realtime-exp"}}))
      file,err:=os.OpenFile("music.pcm",os.O_CREATE|os.O_EXCL|os.O_WRONLY,0600);check(err);defer file.Close()
      receivedChunks:=0
      ready:=false
      for {
        _,raw,err:=ws.ReadMessage(); if err!=nil {
          if networkErr,ok:=err.(interface{Timeout()bool});ok&&networkErr.Timeout()&&receivedChunks>0 {fmt.Println("采样窗口结束，已收到音频块",receivedChunks);return};panic(err)
        }
        var event map[string]json.RawMessage;check(json.Unmarshal(raw,&event))
        if value,ok:=event["error"];ok {panic(string(value))}
        if value,ok:=event["filteredPrompt"];ok {panic(string(value))}
        if _,ok:=event["setupComplete"];ok&&!ready {
          ready=true
          check(ws.WriteJSON(map[string]any{"clientContent":map[string]any{"weightedPrompts":[]any{map[string]any{"text":"minimal techno","weight":1}}}}))
          check(ws.WriteJSON(map[string]any{"musicGenerationConfig":map[string]any{"bpm":90}}))
          check(ws.WriteJSON(map[string]any{"playbackControl":"PLAY"}))
        }
        if value,ok:=event["serverContent"];ok {
          var content struct {AudioChunks []struct {Data string `json:"data"`; MIME string `json:"mimeType"`} `json:"audioChunks"`}
          check(json.Unmarshal(value,&content))
          for _,chunk:=range content.AudioChunks {data,err:=base64.StdEncoding.DecodeString(chunk.Data);check(err);_,err=file.Write(data);check(err);if len(data)>0 {receivedChunks++};fmt.Println(chunk.MIME)}
        }
      }
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

À l’établissement de connexion, HTTP 400/401/403 indique un problème d’adresse, de clé, d’autorisation ou de modèle ; 429 indique quota ou limitation. Ensuite, les erreurs apparaissent dans error, filteredPrompt, warning et le code/motif de fermeture WebSocket. 1000 indique une fermeture normale ; une coupure anormale ne garantit pas l’annulation de la tâche ou de sa facturation. Une reconnexion exige un nouveau setup ; ne supposez pas l’ancien état conservé.

## Références officielles

[Musique en temps réel Google](https\://ai.google.dev/gemini-api/docs/realtime-music-generation), [Live Music WebSocket API](https\://ai.google.dev/api/live_music).