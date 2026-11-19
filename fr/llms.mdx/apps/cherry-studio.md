# Configuration de Cherry Studio

Cherry Studio est un client IA de bureau compatible avec plusieurs fournisseurs. Les étapes suivantes utilisent une clé API SimiRouter.

* Site officiel \: [https\://cherry-ai.com](https\://cherry-ai.com/)
* Téléchargement \: [https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* Documentation officielle \: [https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## Connecter SimiRouter

### Méthode 1 \: ouvrir depuis la page des clés

1. Installez et lancez Cherry Studio, puis ouvrez dans SimiRouter [Gestion des clés API](https://api.dwchainless.com/keys) pour trouver la clé à utiliser.
2. À droite de cette clé, cliquez sur **…**, puis choisissez **Cherry Studio**, puis autorisez le navigateur à ouvrir l’application.
3. Dans Cherry Studio, vérifiez l’adresse API, la clé et le modèle importés. L’adresse doit être `https://api.dwchainless.com`. Enregistrez, puis choisissez un modèle accessible au compte.

### Méthode 2 \: configuration manuelle

1. Dans [Gestion des clés API](https://api.dwchainless.com/keys) copiez la clé API ; vous pouvez également utiliser **…** à droite de la clé et « Copier les informations de connexion » pour obtenir l’adresse.
2. Dans Cherry Studio, ouvrez **Paramètres → Services de modèles**, puis choisissez **New API**. Renseignez l’adresse API `https://api.dwchainless.com`, puis collez la clé copiée précédemment.
3. Cliquez sur Gérer pour ajouter ou sélectionner un modèle accessible au compte. Activez le fournisseur, puis revenez à la conversation.

![Configuration de l’adresse API et de la clé dans Cherry Studio](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="Protéger la clé">
  Ne publiez pas la clé API dans une capture et ne la confiez pas à une application non fiable. Après un bref message de test, vérifiez le modèle et l’appel dans les journaux SimiRouter.
</Callout>

## Générer des images dans Cherry Studio

1. Ajoutez un modèle d’image accessible au compte dont le format d’API est pris en charge par Cherry Studio.
   ![Ajout d’un modèle d’image dans Cherry Studio](/simidoc/assets/cherry_studio/add_paint_models.png)

2. Dans la page d’image, choisissez le modèle et saisissez une invite, puis vérifiez le résultat.
   ![Page de génération d’images et zone d’invite Cherry Studio](/simidoc/assets/cherry_studio/paint.png)