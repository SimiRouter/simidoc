# Utiliser l’API avec des scripts

Utilisez Chat Completions pour envoyer des messages et lire la réponse du modèle. Les quatre langages ci-dessous effectuent la même opération \: ils envoient à `POST /v1/chat/completions` une requête JSON non diffusée en continu, attendent la réponse complète, puis affichent le résultat.

## Scripts d’appel d’image

Consultez les [API d’images](/simidoc/fr/apps/api/images) pour choisir un protocole et retrouver ses exemples de génération, d’édition et d’enregistrement.

## Préparer la clé et le modèle

Dans [Gestion des clés API](https://api.dwchainless.com/keys) créez une clé, puis ouvrez [Place des modèles](https://api.dwchainless.com/fr/pricing/) pour copier l’ID complet d’un modèle accessible avec cette clé. Les exemples lisent la configuration dans des variables d’environnement et ne stockent pas la clé dans un fichier.

* `SIMIROUTER_API_KEY` \: clé API SimiRouter, obligatoire.
* `SIMIROUTER_MODEL` \: ID complet du modèle, obligatoire.
* `SIMIROUTER_BASE_URL` \: facultatif, valeur par défaut \: `https://api.dwchainless.com`. Cette variable contient l’adresse racine, sans `/v1`.

Définissez ces valeurs dans votre terminal ou dans les variables d’environnement de la plateforme d’exécution. N’affichez pas la clé dans des journaux publics. Les appels API réels peuvent être facturés.

## Utiliser le SDK OpenAI (remplacement direct)

Si votre code utilise déjà le SDK officiel OpenAI, remplacez uniquement `baseURL` et `apiKey`, puis utilisez un identifiant de modèle complet de SimiRouter. `baseURL` doit se terminer par `/v1` ; les noms de méthodes, les paramètres et les objets de réponse conservent la forme OpenAI.

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
    ```python
    import os
    from openai import OpenAI

    client = OpenAI(
        base_url="https://api.dwchainless.com/v1",
        api_key=os.environ["SIMIROUTER_API_KEY"],
    )
    response = client.chat.completions.create(
        model=os.environ["SIMIROUTER_MODEL"],
        messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
    )
    print(response.choices[0].message.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    import OpenAI from 'openai';

    const client = new OpenAI({
      baseURL: 'https://api.dwchainless.com/v1',
      apiKey: process.env.SIMIROUTER_API_KEY,
    });
    const response = await client.chat.completions.create({
      model: process.env.SIMIROUTER_MODEL,
      messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
    });
    console.log(response.choices[0].message.content);
    ```
  </Tab>
</Tabs>

Installez d’abord le SDK officiel \: `pip install openai` ou `npm install openai`. Le SDK gère les nouvelles tentatives, les délais d’expiration et l’analyse SSE ; les options client comme les délais personnalisés et `max_retries` gardent leur sémantique SDK, sans réécriture par la passerelle.

La passerelle répond avec le protocole compatible OpenAI ; les capacités dépendent toujours du modèle choisi. Si le SDK renvoie `404`, vérifiez que `baseURL` n’est pas réglé sur `https://api.dwchainless.com` sans `/v1`.

## Requête et réponse

| Élément                               | Description                                                                                                                |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Méthode et chemin                     | `POST /v1/chat/completions`                                                                                                |
| Authentification                      | `Authorization: Bearer <API Key>`                                                                                          |
| Type de contenu                       | `application/json`                                                                                                         |
| Paramètres obligatoires               | `model`, `messages`                                                                                                        |
| Paramètres facultatifs de cet exemple | `max_completion_tokens: 256`, `stream: false` ; le modèle choisi doit les prendre en charge                                |
| Réponse réussie                       | HTTP 200, `choices[].message.content` contient le texte de la réponse ; `usage` indique la consommation de tokens renvoyée |
| Appel en streaming                    | `stream: true` renvoie du SSE et ne doit pas être analysé comme un objet JSON unique                                       |

Pour tous les paramètres, les appels d’outils, les entrées multimodales et les événements SSE, consultez [Chat Completions](/simidoc/fr/apps/api/chat/openai-chat).

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. Les exemples Python 3, Node.js 18+ et Go utilisent uniquement la bibliothèque standard. L’exemple curl fait encoder le JSON de façon sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP | Causes courantes                                                           | Action recommandée                                                                                                     |
| ----------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 400         | Format de requête incorrect ou paramètres non pris en charge par le modèle | Consultez le corps d’erreur et omettez les paramètres facultatifs non pris en charge                                   |
| 401         | Clé absente, expirée ou incorrecte                                         | Vérifiez les variables d’environnement et recréez une clé si nécessaire                                                |
| 403         | Accès au modèle, au groupe ou au canal limité                              | Vérifiez les autorisations de la clé et du compte                                                                      |
| 404         | Chemin ou identifiant de modèle incorrect                                  | Vérifiez qu’aucun doublon de `/v1` n’a été ajouté et contrôlez l’ID complet du modèle                                  |
| 429         | Limite de débit ou de quota                                                | Vérifiez d’abord le quota et les limites, puis appliquez le délai indiqué par l’erreur ; ne réessayez pas indéfiniment |
| 5xx         | Erreur de la passerelle ou du service amont                                | Conservez le corps d’erreur expurgé et l’ID de requête ; vérifiez l’historique avant de réessayer                      |

Ces statuts servent à orienter le diagnostic ; la réponse d’erreur précise la cause. Une expiration côté client ne prouve pas que le modèle n’a pas exécuté la requête. Ne relancez pas les générations sans limite.

## Autres fonctionnalités

* [Responses](/simidoc/fr/apps/api/chat/openai-responses) \: organiser les requêtes en éléments d’entrée et de sortie.
* [Claude Messages](/simidoc/fr/apps/api/chat/claude) et [Gemini](/simidoc/fr/apps/api/chat/gemini-text) \: structures de messages natives.
* [Générer une image](/simidoc/fr/apps/api/images) \: génération, retouche et reconnaissance.
* [Audio](/simidoc/fr/apps/api/audio) \: compréhension audio, synthèse vocale, transcription et traduction.
* [Vidéo](/simidoc/fr/apps/api/video) \: tâches de génération et compréhension vidéo.
* [Intégration audio MiMo](/simidoc/fr/apps/api/audio/mimo-audio) \: synthèse, transcription et voix MiMo.

## Références officielles

Les champs du protocole sont décrits dans [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create). L’adresse et les clés de SimiRouter diffèrent de celles de l’API directe OpenAI.