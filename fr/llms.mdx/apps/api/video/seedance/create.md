# Créer une tâche vidéo Seedance

## Description de l’interface

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`, `Authorization: Bearer $ARK_API_KEY`, corps JSON. Protocole officiel direct \: **aucune garantie** de correspondance avec le chemin `/v1/video/generations` dans SimiRouter.

## Paramètres de requête

| Champ                     | Type      | Obligatoire  | Description                                                                                                                                                                          |
| ------------------------- | --------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| model                     | string    | Oui          | ID d’un modèle Seedance activé ou d’un point d’accès d’inférence.                                                                                                                    |
| content                   | object\[] | Oui          | Éléments texte, image, vidéo ou audio acceptés par le modèle.                                                                                                                        |
| content\[].type           | string    | Oui          | text, image\_url, video\_url, audio\_url et draft\_task selon les capacités du modèle.                                                                                               |
| content\[].draft\_task.id | string    | Conditionnel | ID de tâche brouillon quand type=draft\_task, pour produire une vidéo finale à partir d’un brouillon.                                                                                |
| content\[].text           | string    | Conditionnel | Consigne de type=text.                                                                                                                                                               |
| content\[].image\_url.url | string    | Conditionnel | Image accessible ou data URL acceptée par le modèle.                                                                                                                                 |
| content\[].role           | string    | Non          | Par exemple first\_frame, last\_frame ou reference\_image selon modèle et média.                                                                                                     |
| resolution                | string    | Non          | Résolution autorisée \: 480p, 720p, 1080p ou 4k selon le modèle ; les brouillons ne prennent en charge que 480p.                                                                     |
| ratio                     | string    | Non          | Par exemple 16\:9, 9\:16, 1\:1 ou adaptive ; consultez le tableau du modèle.                                                                                                         |
| duration                  | integer   | Non          | Durée vidéo selon la plage du modèle ; -1 si la durée automatique est prise en charge.                                                                                               |
| frames                    | integer   | Non          | Nombre de trames pour les modèles compatibles ; envoyé avec duration, frames prévaut.                                                                                                |
| generate\_audio           | boolean   | Non          | Générer une piste audio, uniquement sur les modèles sonores.                                                                                                                         |
| watermark                 | boolean   | Non          | Filigrane visible ; respectez les obligations d’identification des contenus synthétiques.                                                                                            |
| seed                      | integer   | Non          | Graine aléatoire ; la reproduction n’est pas garantie au pixel près.                                                                                                                 |
| return\_last\_frame       | boolean   | Non          | Demande l’image de dernière trame.                                                                                                                                                   |
| callback\_url             | string    | Non          | URL de notification de changement d’état ; gérez doublons et notifications désordonnées.                                                                                             |
| execution\_expires\_after | integer   | Non          | Expiration en secondes \: 172800 par défaut, plage 3600–259200.                                                                                                                      |
| service\_tier             | string    | Non          | default / flex, selon le modèle.                                                                                                                                                     |
| draft                     | boolean   | Non          | Crée une vidéo brouillon ; false par défaut et 480p uniquement sur les modèles compatibles. Pour produire la vidéo finale depuis un brouillon, utilisez `content[].type=draft_task`. |
| priority                  | integer   | Non          | Priorité de file pour les modèles/niveaux de service compatibles, pas tous les appels.                                                                                               |

L’exemple choisit Seedance 2.5, avec texte seul et paramètres de courte vidéo. Pour 1.0 pro / 2.0, adaptez les champs aux capacités de la version ; références multimodales, audio et brouillons ne sont pas tous garantis.

## Valeur de retour

Une création réussie renvoie `id`, pas une vidéo terminée. Conservez l’ID puis utilisez [Interface de consultation](/simidoc/fr/apps/api/video/seedance/status).

```json
{"id":"cgt-example"}
```

Un délai dépassé ne prouve pas que le serveur n’a rien accepté \: évitez les créations répétées sans limite. Les rappels doivent mettre l’état à jour de manière idempotente selon l’ID de tâche.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez la variable officielle `ARK_API_KEY` ; l’appel crée une tâche potentiellement facturable.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP           | Sens et traitement                                                                                                                                   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Champs, média ou paramètres de modèle invalides ; corrigez avant de soumettre.                                                                       |
| 401                   | Clé API absente, invalide ou expirée.                                                                                                                |
| 403                   | Projet ou modèle non autorisé.                                                                                                                       |
| 404                   | Modèle, route ou tâche introuvable ; vérifiez l’adresse et le propriétaire.                                                                          |
| 413 / 415             | Fichier trop volumineux ou type de média non pris en charge.                                                                                         |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                            |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont \: conservez l’ID. Après expiration d’une création, vérifiez l’acceptation avant de relancer pour éviter un doublon. |

L’objet d’erreur Volcengine utilise `error.code`, `error.message` ; conservez aussi l’ID de requête. Consultez le résultat pour un échec d’exécution ; le code HTTP de création ne prouve pas une réussite finale.

Les erreurs Volcengine utilisent `error.code`, `error.message` et l’ID de requête ; un échec de génération se lit aussi dans error du résultat de consultation.

## Références officielles

[Création de tâche Volcengine Ark](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Tutoriel officiel d’appel](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).