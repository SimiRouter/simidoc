# OpenAI Realtime API

## Description de l’interface

Realtime offre des échanges vocaux et textuels à faible latence avec état \: le client émet continuellement des événements et le serveur renvoie audio, texte et appels d’outils. Il est indépendant de [TTS](/simidoc/fr/apps/api/audio/speech), [Transcription de fichiers](/simidoc/fr/apps/api/audio/transcriptions) et [Traduction de fichiers](/simidoc/fr/apps/api/audio/translations).

| Scénario                  | Intégration officielle                                                           | Authentification                                                          |
| ------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| WebSocket côté serveur    | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1`                        | OpenAI API Key Bearer                                                     |
| WebRTC dans le navigateur | `/v1/realtime/calls` ; créez d’abord des identifiants temporaires sur le serveur | Client secret de courte durée ; ne pas exposer de clé standard            |
| Transcription continue    | Configuration de session dédiée Realtime transcription                           | Utilise intent/config appropriés ; différent d’une conversation ordinaire |

Les exemples appellent directement OpenAI ; la mise à niveau WebSocket, le relais d’événements et les autorisations de modèle SimiRouter doivent être confirmés sur un canal dédié. Un simple HTTP GET ne prouve pas une connexion temps réel réussie. Le protocole GA n’utilise pas l’ancien `OpenAI-Beta: realtime=v1`.

## Paramètres de requête

| Champ                             | Type           | Obligatoire  | Description                                                                                                               |
| --------------------------------- | -------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------- |
| model (paramètre de connexion)    | string         | Conditionnel | Modèle de création de session, par exemple gpt-realtime-2.1 ; pour rejoindre un call existant, utilisez call\_id.         |
| call\_id (paramètre de connexion) | string         | Conditionnel | Rejoint un appel établi ; à distinguer du modèle de création d’une nouvelle session.                                      |
| session.type                      | string         | Oui          | Une mise à jour de session utilise realtime ; la transcription a une configuration distincte.                             |
| session.instructions              | string         | Non          | Instructions système de comportement et de style.                                                                         |
| session.output\_modalities        | string\[]      | Non          | text ou audio, selon la configuration Realtime courante.                                                                  |
| session.audio                     | object         | Non          | Formats audio d’entrée/sortie, voix et détection de parole ; doivent correspondre aux encodages de capture et de lecture. |
| session.tools / tool\_choice      | array / string | Non          | Définition et sélection des outils ; validez les arguments côté application.                                              |
| event\_id                         | string         | Non          | ID de suivi client pour associer les événements d’erreur.                                                                 |

### Événements clients courants

| Événement                   | Utilité                                                                             |
| --------------------------- | ----------------------------------------------------------------------------------- |
| `session.update`            | Met à jour la session ; attendez session.updated pour lire sa configuration réelle. |
| `conversation.item.create`  | Ajoute à la session du texte ou d’autres éléments autorisés.                        |
| `input_audio_buffer.append` | Bloc audio Base64 dont l’encodage doit correspondre à session.audio.input.format.   |
| `input_audio_buffer.commit` | Valide le tampon ; valider ne crée pas automatiquement une réponse.                 |
| `input_audio_buffer.clear`  | Abandonne les entrées non validées.                                                 |
| `response.create`           | Demande la génération d’une réponse.                                                |
| `response.cancel`           | Annule la génération en cours ; la lecture doit aussi gérer l’audio déjà en tampon. |

Un microphone continu doit envoyer des blocs à la fréquence d’échantillonnage réelle ; VAD décide de la validation et génération automatiques. Lors d’une interruption, il faut aussi vider le tampon de lecture ou tronquer l’élément de session selon le protocole officiel ; arrêter le haut-parleur ne suffit pas.

## Valeur de retour

| Événements serveur                       | Champs clés / signification                                        |
| ---------------------------------------- | ------------------------------------------------------------------ |
| `session.created` / `session.updated`    | Identifiant et configuration réelle de la session.                 |
| `response.output_text.delta`             | delta \: ajout de texte.                                           |
| `response.output_audio.delta`            | delta \: ajout audio en Base64, à décoder.                         |
| `response.output_audio_transcript.delta` | Texte associé à la parole ; ne remplace pas l’audio.               |
| `response.done`                          | response.status et usage ; seul completed indique une fin normale. |
| `error`                                  | error.type, code, message, event\_id, etc.                         |

Realtime repose sur des événements WebSocket bidirectionnels, pas sur les SSE de `data:`. Une déconnexion ou un audio partiel ne constitue pas une réussite complète ; la longueur du texte ne permet pas de déduire la facturation finale.

## Exemples de code

Définissez la variable officielle `OPENAI_API_KEY`. Python nécessite `python3 -m pip install websockets` ; Node.js nécessite `npm install ws` ; Go nécessite `go get github.com/gorilla/websocket`. Les exemples envoient un échange de **texte** pour vérifier le cycle complet d’événements, sans intégrer microphone ni haut-parleur ; attente maximale de 60 secondes.

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

## Codes d’erreur

À l’établissement de connexion, HTTP 400/401/403/404/429 renseigne sur paramètres, authentification, autorisations, modèle et quota. Après connexion, traitez les événements error, les états d’échec de response.done et le code/motif de fermeture WebSocket. Signalez comme incomplètes les coupures anormales ou expirations ; après reconnexion, reconstruisez l’état sans rejouer aveuglément des outils ou opérations à effets de bord déjà déclenchés.

## Références officielles

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect), [Événements clients](https\://developers.openai.com/api/reference/resources/realtime/client-events), [Événements serveur](https\://developers.openai.com/api/reference/resources/realtime/server-events), [Guide Realtime](https\://developers.openai.com/api/docs/guides/realtime).