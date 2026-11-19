# Configuration d’une extension tierce (VS Code Roo)

Roo Code prend en charge les fournisseurs OpenAI compatibles personnalisés. Pour SimiRouter, renseignez l’adresse, la clé et l’ID du modèle ; aucun déploiement local de modèle n’est nécessaire.

## Configurer Roo Code

1. Installez Roo Code et ouvrez les paramètres de l’extension.
2. Réglez **API Provider** sur **OpenAI Compatible**.
3. Renseignez les informations suivantes \:

| Champ    | Valeur                                                                            |
| -------- | --------------------------------------------------------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`                                                  |
| API Key  | SimiRouter [Gestion des clés API](https://api.dwchainless.com/keys) \: utilisez la clé créée dans cette page |
| Model ID | Depuis [Place des modèles](https://api.dwchainless.com/fr/pricing/) copiez l’ID complet, en respectant la casse  |

4. Définissez la fenêtre de contexte, la sortie maximale et les images selon les capacités réelles du modèle. Ne recopiez pas les limites d’un autre modèle. Roo Code utilise toujours l’appel d’outils natif ; il n’existe pas d’option séparée.
5. Enregistrez, envoyez un bref message, puis ouvrez dans SimiRouter [Journaux d’utilisation](https://api.dwchainless.com/usage-logs/common) pour vérifier l’appel.

## Tester l’interface

Pour des tests complets en Python, Node.js, curl et Go hors du client, consultez [Utiliser l’API avec des scripts](/simidoc/fr/apps/api-script). Le test et l’extension doivent utiliser le même modèle et les mêmes autorisations. Un appel textuel réussi ne valide pas l’intégration des images ou des outils.

## Erreurs fréquentes

* **401** \: vérifiez que la clé est complète, valide et sans espace superflu.
* **404** \: vérifiez si l’URL finale comporte un doublon de `/v1` et contrôlez l’ID du modèle.
* **Modèle indisponible** \: vérifiez le modèle, le groupe et les autorisations avec le corps d’erreur.
* **Paramètre non pris en charge** \: désactivez les paramètres incompatibles, notamment l’échantillonnage, l’effort de raisonnement et la longueur de sortie.

Conservez les confirmations d’outils par défaut. N’autorisez pas l’exécution automatique dans un projet non fiable et ne publiez pas les réglages contenant une clé.

## Références officielles

[Roo Code \: fournisseur OpenAI Compatible](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/).