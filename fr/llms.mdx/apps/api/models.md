# Liste des modèles

La liste des modèles est le point d’entrée de la configuration \: obtenez d’abord l’ID du modèle, puis choisissez l’interface de chat, vision, image, audio ou outils selon la documentation des capacités du fournisseur. Visible ne signifie pas appelable, et la liste ne constitue pas un contrôle de santé en temps réel.

## Aperçu

| Ce que vous devez vérifier          | Où le voir                                                 | Explication                                                                                    |
| ----------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Quels ID de modèles existent        | L’interface de liste de cette section                      | Renvoie uniquement les modèles visibles avec les identifiants actuels                          |
| Possibilité d’appeler réellement    | Modèles et tarifs + une requête réelle                     | Visible, routable et disposant d’un quota sont trois choses distinctes                         |
| Entrées et sorties prises en charge | Documentation des capacités du modèle                      | Les métadonnées de la liste sont souvent incomplètes                                           |
| Date de retrait                     | Avis officiel de dépréciation ou de retrait du fournisseur | Une dépréciation n’implique pas une indisponibilité immédiate, mais il ne faut plus l’intégrer |

## Concepts clés

* **ID de modèle** \: identifiant unique utilisé dans le corps de requête, généralement sensible à la casse ; copiez-le intégralement sans l’abréger. Le nom affiché, les alias et l’ID réel de requête peuvent différer.
* **Visible et appelable** \: la liste ne reflète que les modèles dans le périmètre d’autorisation ; un canal non configuré, un solde insuffisant ou une limitation de débit provoquent encore un échec.
* **Fenêtre de contexte** \: limite de tokens en entrée plus sortie, variable selon le modèle ; l’interface de liste ne renvoie souvent pas cette valeur.
* **Unité de facturation** \: les modèles texte facturent surtout au token, les modèles image à l’image ou au token, les modèles vidéo souvent à la seconde ou à l’appel ; cela peut varier au sein d’une même famille.
* **Date de retrait** \: date prévue par le fournisseur pour l’arrêt du service ; la migration doit être terminée avant l’échéance, pas découverte après.

## Interface de consultation

| Documentation             | Requête            | Structure renvoyée                                      |
| ------------------------- | ------------------ | ------------------------------------------------------- |
| [Format OpenAI](/simidoc/fr/apps/api/models/openai) | GET /v1/models     | data\[].id, adapté aux clients compatibles OpenAI.      |
| [Format Gemini](/simidoc/fr/apps/api/models/gemini) | GET /v1beta/models | models\[].name, adapté aux clients du protocole Gemini. |

## Mode d’appel

La consultation de liste est une requête JSON synchrone, sans SSE ni tâche asynchrone. Plusieurs comptes peuvent être interrogés en parallèle, mais les identifiants et résultats ne doivent pas être mélangés. Le cache de liste doit avoir une durée de validité ; relisez-la lorsqu’un modèle devient indisponible ; n’envoyez pas de vraie requête de génération pour rafraîchir la liste.

## Appel simulé

Envoyez une requête GET sans corps. Voici un exemple de réponse de la passerelle SimiRouter \:

```bash
curl "https://api.dwchainless.com/v1/models" \
  -H "Authorization: Bearer $SIMIROUTER_API_KEY"
```

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

La passerelle indique une longueur de contexte et des types d’endpoints. La longueur peut correspondre à la valeur par défaut de la plateforme. Consultez la documentation du modèle pour connaître ses tarifs, ses modalités d’entrée et de sortie et sa prise en charge des outils. Une liste vide indique généralement que les identifiants actuels ne donnent accès à aucun modèle.

## Limites des métadonnées

L’objet modèle OpenAI contient id, object, created et owned\_by ; l’objet modèle natif Google peut inclure des méthodes et des limites de tokens. La passerelle peut ne renvoyer que des métadonnées réduites \: ne déduisez pas une limite de contexte, une modalité ou la prise en charge d’outils à partir de champs absents.

## Références officielles

* [API Models OpenAI](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [API Models Google](https\://ai.google.dev/api/models)