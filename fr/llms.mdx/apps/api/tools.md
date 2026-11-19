# Appels d’outils

L’appel d’outils relie le modèle aux données, aux calculs et aux services externes. Le modèle choisit l’outil et organise les arguments ; l’application ou le service d’outils du fournisseur exécute. La valeur renvoyée par l’outil et la réponse finale en langage naturel sont des étapes distinctes.

## Aperçu

| Capacité               | Qui exécute     | Résultat visible                                           | Cas typique                                                                   |
| ---------------------- | --------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Fonction côté client   | Votre programme | Intention d’appel + résultat d’exécution que vous renvoyez | Interroger une base de données, appeler une API interne, décrémenter un stock |
| Recherche côté serveur | Le fournisseur  | Réponse finale et sources citées                           | Consulter des informations récentes, vérifier des faits                       |

## Concepts clés

* **Définition d’outil** \: nom, description de l’usage et JSON Schema des paramètres. Plus la description est claire, plus le risque que le modèle choisisse le mauvais outil ou invente des paramètres diminue.
* **Intention d’appel** \: le modèle n’exécute pas de code et renvoie seulement `tool_calls`, dont `arguments` est une chaîne JSON. Elle peut arriver en fragments dans une réponse en streaming ; rassemblez-la entièrement avant de l’analyser.
* **Exécution et retour** \: votre programme valide les paramètres, exécute la fonction, puis renvoie le résultat dans un message dont `role` vaut `tool` et qui porte le même `tool_call_id` ; le modèle peut alors continuer.
* **Outils côté serveur** \: la recherche est effectuée par le fournisseur, vous recevez seulement la réponse et les citations, sans contrôler le processus intermédiaire ; ne transposez pas l’usage des fonctions côté client.

## Appel simulé

Une requête de fonction côté client, la réponse du modèle et le résultat renvoyé se présentent comme suit (contenu indicatif) \:

```json
{
  "model": "gpt-5.5",
  "messages": [{ "role": "user", "content": "上海今天多少度？" }],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "查询指定城市的实时天气",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }
  ]
}
```

Le modèle renvoie une intention d’appel plutôt que la température \:

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc",
            "type": "function",
            "function": {
              "name": "get_weather",
              "arguments": "{\"city\":\"上海\"}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

Après avoir exécuté la fonction, ajoutez le résultat comme nouveau message et relancez la requête \:

```json
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"temp_c\": 18}"
}
```

La troisième réponse est la réponse en langage naturel destinée à l’utilisateur. Dans toute cette chaîne, le modèle n’a jamais réellement accédé au service météo ; c’est votre programme qui exécute.

### Recherche côté serveur

Un outil côté serveur ne demande qu’un aller-retour \: vous déclarez l’outil, le fournisseur effectue la recherche, et une seule réponse contient à la fois le journal de recherche et la réponse finale.

```json
{
  "model": "gpt-5.5",
  "input": "查找 OpenAI 官方文档中关于 Responses API 的说明，并提供来源链接。",
  "tools": [{ "type": "web_search" }],
  "stream": false
}
```

Le tableau `output[]` renvoyé présente généralement d’abord l’action de recherche, puis le message final avec les citations \:

```json
{
  "status": "completed",
  "output": [
    {
      "type": "web_search_call",
      "status": "completed",
      "action": { "type": "search", "query": "site:developers.openai.com Responses API" }
    },
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 用于生成模型响应……",
          "annotations": [
            {
              "type": "url_citation",
              "url": "https://developers.openai.com/api/docs/guides/text",
              "title": "OpenAI text generation"
            }
          ]
        }
      ]
    }
  ]
}
```

La réponse n’est exploitable que si `status` vaut `completed` et qu’un `message` existe ; voir uniquement un `web_search_call` signifie que la phase de recherche est terminée, pas que la réponse est complète. Les citations proviennent de `annotations[]` et doivent être affichées telles quelles, sans réécrire les URL sources.

## Types d’outils

| Documentation                        | Requête                                                      | Exécutant                                                                                     |
| ------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| [Appel de fonction](/simidoc/fr/apps/api/tools/function-call) | POST /v1/chat/completions ; le format Responses existe aussi | L’application définit le JSON Schema, valide les paramètres et exécute ses propres fonctions. |
| [Recherche Web](/simidoc/fr/apps/api/tools/web-search)        | POST /v1/responses + web\_search                             | Recherche hébergée par le fournisseur, renvoyant pages sources et citations.                  |

## Synchrone, streaming et parallèle

* **Synchrone** \: une requête renvoie un appel d’outil complet ou la réponse finale ; une fonction personnalisée nécessite généralement son exécution par l’application, puis une nouvelle requête.
* **Streaming** \: le nom de l’outil ou les arguments apparaissent par fragments ; analysez-les une fois les arguments complets, sans exécuter un JSON partiel.
* **Asynchrone** \: l’application peut créer une tâche de fond pour un outil métier lent, mais doit fournir elle-même l’état de la tâche et la corrélation des résultats ; déclarer tools ne crée pas automatiquement un service asynchrone.
* **Parallèle** \: parallel\_tool\_calls permet au modèle de proposer plusieurs appels de fonction dans un même tour ; l’application ne doit exécuter en parallèle que des opérations autorisées et indépendantes. Cela n’augmente pas automatiquement le quota de limitation et ne signifie pas plusieurs requêtes HTTP.

## Limites de sécurité

Fixez une liste blanche d’outils, validez les types et le périmètre métier, séparez les droits de lecture et d’écriture. Les effets de bord tels que l’envoi externe, le paiement, la suppression et la modification d’autorisations doivent être soumis à confirmation et à un contrôle d’idempotence. La sortie d’un outil peut contenir du texte non fiable \: ne la traitez pas comme de nouvelles instructions système.

## Références officielles

* [Appels de fonctions OpenAI](https\://developers.openai.com/api/docs/guides/function-calling)
* [Recherche Web OpenAI](https\://developers.openai.com/api/docs/guides/tools-web-search)