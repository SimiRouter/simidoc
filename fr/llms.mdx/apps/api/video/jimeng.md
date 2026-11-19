# Vidéo Jimeng (intégration prévue)

## Description de l’interface

L’API vidéo officielle Jimeng propose via **Volcengine Visual** une conversion synchrone-vers-asynchrone pour texte vers vidéo et image de première trame vers vidéo. Elle utilise une passerelle et une authentification différentes de **Seedance de Volcengine Ark**, sans clé Bearer commune.

| Étape     | Requête officielle                                                                        | Documentation                     |
| --------- | ----------------------------------------------------------------------------------------- | --------------------------------- |
| Soumettre | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [Soumettre une tâche](/simidoc/fr/apps/api/video/jimeng/create)   |
| Consulter | POST sur le même hôte, Action=CVSync2AsyncGetResult                                       | [Consulter le résultat](/simidoc/fr/apps/api/video/jimeng/status) |

Cette section conserve la référence officielle Jimeng 3.0 Pro, marquée « en cours de retrait ». Vérifiez dans la console Volcengine produits et versions encore activables pour votre compte. Jimeng est une référence d’intégration prévue SimiRouter, sans promesse d’appel public sans configuration explicite.

## Authentification et déroulement asynchrone

L’API officielle utilise une signature V4 HMAC-SHA256 AK/SK, Region=`cn-north-1`, Service=`cv`. Authorization n’est pas Bearer ; la signature couvre méthode, chemin, query, en-têtes indiqués et hachage du corps.

Après soumission code=10000, récupérez data.task\_id et consultez avec le même req\_key et task\_id. Les états sont in\_queue, generating, done, not\_found et expired. **done signifie seulement la fin du traitement, pas sa réussite** ; vérifiez aussi code, message et video\_url. Cette interface n’a ni flux vidéo temps réel ni SSE.

## Références officielles

[Interface Jimeng 3.0 Pro](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Implémentation officielle de signature Volcengine](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).