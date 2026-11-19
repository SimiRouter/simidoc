# Conversation et génération de contenu

L’API de conversation transforme une conversation ou une instruction en sortie de modèle. Elle peut répondre uniquement en texte, lire des images, de l’audio et des fichiers, ou appeler des outils externes avant de répondre. Le protocole détermine la forme des requêtes et des réponses ; le modèle détermine les modalités d’entrée disponibles, la longueur du contexte et les capacités d’outils.

## Aperçu

| Ce que vous voulez faire                                                                                       | Choisir                                           | Point clé                                                           |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------- |
| Questions-réponses ordinaires, rédaction, résumé                                                               | [Chat Completions](/simidoc/fr/apps/api/chat/openai-chat)                 | Le plus universel, le plus largement pris en charge par les clients |
| Permettre au modèle de chercher des informations, d’appeler des fonctions, de renvoyer des données structurées | [Responses](/simidoc/fr/apps/api/chat/openai-responses)                   | Entrées et sorties typées et outils intégrés                        |
| Migrer un client Claude existant                                                                               | [Claude Messages](/simidoc/fr/apps/api/chat/claude)                       | Blocs de contenu Anthropic et protocole d’outils                    |
| Migrer un client Gemini existant                                                                               | [Gemini generateContent](/simidoc/fr/apps/api/chat/gemini-text)           | Entrée multimodale parts                                            |
| Maintenir une intégration de complétion héritée                                                                | [Completions](/simidoc/fr/apps/api/chat/openai-completions)               | Prompts texte uniquement, en cours d’abandon                        |
| Permettre au modèle de lire des images, d’écouter de l’audio, de regarder des vidéos ou des PDF                | [Compréhension des médias Gemini](/simidoc/fr/apps/api/chat/gemini-media) | L’entrée est un média, la sortie reste du texte                     |

Tous les protocoles partagent la même authentification de passerelle \: l’URL de base `https://api.dwchainless.com` et l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. Changer de protocole ne change pas la clé, mais changer de modèle exige de vérifier que le nouveau modèle prend en charge les modalités d’entrée et les paramètres dont vous avez besoin.

## Concepts clés

Comprenez d’abord ces termes ; tous les paramètres ci-dessous en dépendent.

* **Token** \: la plus petite unité de facturation du texte que le modèle lit et écrit. Environ 4 caractères anglais ou 1 à 2 caractères chinois comptent pour un token, selon le tokeniseur du modèle. Les tokens d’entrée et de sortie sont facturés séparément.
* **Fenêtre de contexte (context window)** \: la limite totale de tokens en entrée et en sortie pour une requête. Plus l’historique est long, moins il reste de place pour la réponse ; dépasser la limite peut entraîner le rejet de la requête, ou sa troncature avec un `finish_reason` valant `length`.
* **Rôle de message (role)** \: `system` ou `developer` définit les limites de comportement, `user` est l’entrée utilisateur, `assistant` est la sortie du modèle, `tool` renvoie le résultat d’un outil. L’ordre des rôles constitue à lui seul l’historique de la conversation.
* **Sans état** \: le serveur ne stocke pas votre conversation. Chaque requête doit renvoyer l’historique nécessaire, et plus l’historique est long, plus le coût est élevé.
* **Streaming** \: le serveur renvoie des incréments via SSE pour que le client affiche au fur et à mesure. Cela réduit le délai avant le premier token, pas la durée totale ni le coût, et ce n’est pas une tâche asynchrone.
* **Appel d’outils (tool calling)** \: le modèle n’exécute pas les fonctions. Il renvoie une intention d’appel structurée ; votre programme l’exécute et renvoie le résultat comme un nouveau message, puis le modèle poursuit sa réponse.

## Spécifications et capacités

| Indicateur                   | Description                                                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Modalités d’entrée           | Texte ; images, audio, PDF et vidéo selon le modèle                                                                     |
| Modalités de sortie          | Texte ; certains modèles prennent en charge le JSON structuré ou les images                                             |
| Longueur du contexte         | Variable selon le modèle, généralement de 8K à 1M tokens                                                                |
| Limite de sortie par réponse | Chat utilise `max_completion_tokens`, Responses utilise `max_output_tokens`, et est bornée par la limite du modèle      |
| Concurrence                  | Définie par votre quota et les limites de débit du canal, sans lien avec `n` et `parallel_tool_calls`                   |
| Facturation                  | Tokens d’entrée et de sortie facturés séparément ; les tokens d’outils et de raisonnement peuvent être facturés en plus |

Plus de paramètres ne signifie pas mieux \: `temperature`, `top_p`, `reasoning_effort` et d’autres paramètres d’échantillonnage ou de raisonnement sont pris en charge à des degrés variables selon les modèles. La passerelle les transmet au canal ; ceux qui ne sont pas pris en charge peuvent provoquer une erreur ou être ignorés. Envoyez d’abord une requête minimale, puis ajoutez les paramètres un par un.

## Flux d’appel

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez l’ID de modèle complet depuis Modèles et prix.
2. **Choisir l’interface** \: Chat Completions pour les cas généraux ; Responses lorsque vous avez besoin d’outils, de sorties structurées ou du mode arrière-plan ; le protocole natif correspondant lors de la migration d’un client.
3. **Envoyer d’abord une requête non streaming** \: demandez une seule réponse pour confirmer l’authentification, le modèle et les paramètres, puis activez le streaming ou les outils.
4. **Lire et valider** \: vérifiez le statut HTTP, `finish_reason`, les informations de refus et le contenu réel, puis contrôlez le journal d’utilisation et le coût.

## Appel simulé

La requête minimale suivante montre trois formes \: le corps de la requête, la réponse complète et une réponse en streaming. Les valeurs et les textes sont illustratifs et ne proviennent pas d’un compte réel.

**Requête**

```json
{
  "model": "gpt-5.5",
  "messages": [
    { "role": "system", "content": "You are a concise technical documentation assistant." },
    { "role": "user", "content": "Explain what a token is in three sentences." }
  ],
  "max_completion_tokens": 300,
  "stream": false
}
```

**Réponse complète (non streaming)**

```json
{
  "id": "chatcmpl_demo_0001",
  "object": "chat.completion",
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "A token is a small unit of text processed by the model. It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 58,
    "total_tokens": 100
  }
}
```

**Réponse en streaming (`"stream": true`)**

Le serveur pousse des incréments sous forme d’événements SSE. Le client concatène `delta.content` dans l’ordre et s’arrête à `[DONE]` \:

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

Le critère de réussite n’est pas « des données sont arrivées », mais \: un statut HTTP 2xx, un `finish_reason` final cohérent et un texte concaténé complet. Si le flux se coupe, terminez avec ce que vous avez reçu plutôt que de renvoyer automatiquement la même requête payante.

## Appel d’outils

L’appel d’outils se présente sous deux formes, et les confondre est une source fréquente d’erreurs \:

* **Fonctions côté client (function calling)** \: vous déclarez la signature de la fonction, le modèle renvoie une intention d’appel, votre programme l’exécute et renvoie le résultat au modèle. Les données et l’exécution restent de votre côté.
* **Outils côté serveur (server-side tools)** \: exécutés du côté du modèle, par exemple la recherche web intégrée de Responses. Vous ne voyez que la réponse finale et les citations, pas le processus de récupération intermédiaire.

Un aller-retour complet d’une fonction côté client se présente comme suit \:

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

Points clés \: `arguments` est une chaîne JSON et non un objet ; le résultat de l’outil doit porter le `tool_call_id` correspondant ; un tour peut contenir plusieurs appels d’outils, et `parallel_tool_calls` contrôle s’ils sont demandés en parallèle. L’appel d’outils consomme des tokens supplémentaires, et les nouvelles tentatives après erreur peuvent être facturées à nouveau.

## Modes d’appel

* **Synchrone non streaming** \: la connexion reste ouverte jusqu’à la fin de la génération et renvoie un JSON complet en une fois. Adapté aux réponses courtes et au traitement par lots côté serveur.
* **Streaming** \: la même requête renvoie des événements de façon incrémentale via SSE. Vous devez gérer les raisons de terminaison et les coupures en cours de flux.
* **Tâches asynchrones en arrière-plan** \: obtenez d’abord un ID de tâche ou de réponse, puis récupérez le résultat par interrogation ou Webhook. Les Responses natives d’OpenAI proposent un flux de travail en arrière-plan, mais la passerelle de ce site n’a pas d’endpoints de consultation ou d’annulation correspondants ; il ne suffit donc pas d’ajouter le paramètre `background`.
* **Requêtes parallèles** \: le client lance plusieurs requêtes HTTP indépendantes et traite séparément les succès, les limitations de débit et les coûts. `n` est le nombre de candidats, et `parallel_tool_calls` désigne plusieurs appels d’outils dans un même tour ; ni l’un ni l’autre n’équivaut à la concurrence HTTP.

## Accès et sessions

Les endpoints de messages ordinaires sont sans état ; incluez l’historique nécessaire à chaque requête. Les ID de réponse avec état dépendent aussi du routage en amont et des limites de conservation des données. Une connexion directe au fournisseur doit changer à la fois le domaine du fournisseur et les identifiants ; remplacer uniquement le nom du modèle ne suffit pas.

## Références officielles

* [Génération de texte OpenAI](https\://developers.openai.com/api/docs/guides/text)
* [Mode arrière-plan OpenAI](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)