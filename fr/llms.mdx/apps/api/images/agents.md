# Appels d’images par agent intégrés aux protocoles

Les tâches d’agent sont réparties entre les trois protocoles. Chacun contient des modèles de génération et d’édition, la préparation, l’enregistrement et la gestion des erreurs ; aucun guide distinct privilégiant OpenAI Images n’est maintenu \:

* [Agent au format OpenAI](/simidoc/fr/apps/api/images/openai) \: génération Images, édition JSON et vérification des événements finaux.
* [Agent au format natif Gemini](/simidoc/fr/apps/api/images/gemini) \: Parts d’image GenerateContent, MIME et contexte sur plusieurs tours.
* [Agent au format natif Qwen](/simidoc/fr/apps/api/images/qwen) \: configuration régionale Model Studio, appels natifs synchrones et téléchargement des URL d’image.

L’agent doit toujours pouvoir exécuter localement et inspecter la réponse ; ces documents n’installent aucun Skill distant. Les requêtes réelles peuvent être facturées \: confirmez modèle, spécifications, quantité et sortie avant l’appel. Ne révélez pas de clé, n’écrasez pas de fichier et ne réessayez pas automatiquement. Comparez API, effets et spécifications dans la [vue d’ensemble des API d’images](/simidoc/fr/apps/api/images).