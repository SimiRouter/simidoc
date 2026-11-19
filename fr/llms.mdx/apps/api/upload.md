# Fichiers et compréhension du contenu

Il existe deux niveaux \: l’API de téléversement gère les ressources et l’API d’entrée du modèle lit leur contenu pour générer une réponse. Joindre un fichier à une génération ne l’enregistre pas comme ressource réutilisable.

## Aperçu

| Ce que vous voulez faire                            | Mode d’entrée                                   | Où va le fichier                    | Faut-il téléverser d’abord |
| --------------------------------------------------- | ----------------------------------------------- | ----------------------------------- | -------------------------- |
| Faire lire un PDF par le modèle                     | Base64 intégré à la requête ou URL accessible   | Uniquement dans cette requête       | Non                        |
| Réutiliser un fichier sur plusieurs requêtes        | file\_id ou référence de fichier du fournisseur | Ressource de fichier du fournisseur | Oui (Files API officielle) |
| Prétraiter des fichiers nombreux ou très volumineux | Téléverser puis attendre la fin du traitement   | Ressource de fichier du fournisseur | Oui, avec un cycle de vie  |

## Concepts clés

* **Entrée intégrée** \: le fichier est encodé dans le corps de la requête et envoyé avec le message ; il disparaît à la fin de la requête, sans file\_id ni étape de suppression ultérieure.
* **Ressource de fichier** \: téléversez d’abord pour obtenir un id, puis référencez-le dans plusieurs requêtes ; la ressource a un propriétaire, une durée de validité et un quota, et doit être supprimée explicitement.
* **Cycle de vie** \: la fin du téléversement ne signifie ni que l’extraction du texte est terminée ni que le modèle a compris le fichier ; interrogez son état jusqu’à ce qu’il soit traitable avant de lancer l’inférence.
* **Taille et format** \: les limites sont fixées séparément pour la taille du fichier, le nombre de pages et la durée ; compresser une image ne change pas son type de fichier, et un PDF numérisé nécessite encore des capacités OCR.
* **Conservation des données** \: les fournisseurs appliquent des politiques différentes à la conservation du contenu des fichiers et des résultats de reconnaissance ; pour les documents sensibles, confirmez d’abord l’autorisation et les modalités de suppression.

## Requêtes et capacités

| Utilité                                                 | Requête                                       | Limites                                                                                                        |
| ------------------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [Compréhension des PDF](/simidoc/fr/apps/api/upload/file-recognition)             | POST /v1/responses + input\_file              | Base64 intégré, sans Files API.                                                                                |
| Entrée PDF de Chat                                      | POST /v1/chat/completions + type=file         | Utilise l’objet file de Chat, pas la structure Responses.                                                      |
| [Files API](/simidoc/fr/apps/api/pending/files)                           | /v1/files                                     | Non implémenté par la passerelle ; la capacité native officielle ne signifie pas sa disponibilité sur le site. |
| [Compréhension des médias Gemini](/simidoc/fr/apps/api/chat/gemini-media) | POST /v1beta/models/\{model}\:generateContent | inlineData ou fileData selon le cas.                                                                           |

## Mode d’appel

La compréhension intégrée peut renvoyer un JSON synchrone ou des événements textuels en streaming ; il s’agit toujours d’une requête au modèle. Certains téléversements ou prétraitements officiels exigent d’attendre la disponibilité de la ressource \: cela relève de son cycle de vie, pas d’une exécution automatique du modèle en arrière-plan. Plusieurs fichiers peuvent être envoyés dans une requête compatible ou en requêtes parallèles ; contexte, frais et limites de taille totale diffèrent.

Avant de téléverser un fichier sensible, vérifiez l’autorisation de traitement et la politique de données du fournisseur. Pour les gros documents, sélectionnez les pages ou passages utiles à la tâche au lieu d’augmenter l’entrée sans limite. Les résultats doivent conserver leur incertitude ; montants, identifiants et conclusions juridiques ou médicales importants exigent une vérification humaine.

## Appel simulé

La compréhension intégrée s’effectue en une seule requête ; le fichier est placé en Base64 dans `input_file` \:

```json
{
  "model": "gpt-5.5",
  "input": [
    {
      "role": "user",
      "content": [
        { "type": "input_text", "text": "总结这份合同的付款条款。" },
        { "type": "input_file", "filename": "contract.pdf", "file_data": "data:application/pdf;base64,JVBERi0xLjQK..." }
      ]
    }
  ]
}
```

La réponse est un message de modèle ordinaire ; le résultat figure dans `output_text` \:

```json
{
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        { "type": "output_text", "text": "（示意）合同约定分三期付款……" }
      ]
    }
  ]
}
```

Tout au long du processus, il n’y a ni étape de téléversement ni file\_id réutilisable ; pour interroger à nouveau le même fichier, il faut soumettre à nouveau le Base64 ou passer à la ressource de fichier officielle.

## Références officielles

* [Entrée de fichiers OpenAI](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Entrée de fichiers Google](https\://ai.google.dev/gemini-api/docs/file-input-methods)