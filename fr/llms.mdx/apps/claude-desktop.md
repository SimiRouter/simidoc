# Configurer Claude Desktop

Grâce à la fonction **Correspondance de modèles** de CC Switch, un nom du menu Claude Desktop peut être associé au modèle réellement appelé sur SimiRouter. Le guide ci-dessous utilise macOS ; les libellés peuvent varier selon le système et la version.

## Prérequis

1. Installez et ouvrez une version récente de Claude Desktop.
2. Installez une version prenant en charge **Claude Desktop** de [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest), puis ouvrez-la.
3. Connectez-vous à SimiRouter et ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) pour créer ou copier une clé API valide. Vérifiez qu’elle autorise les modèles à configurer.

<Callout type="info" title="">
  La clé API est un identifiant d’accès \: protégez-la, ne la publiez pas en capture et ne la partagez pas. Les noms et autorisations des modèles sont ceux de la console SimiRouter.
</Callout>

## Configurer les correspondances avec CC Switch

### 1. Ajouter un fournisseur personnalisé Claude Desktop

Dans la barre latérale CC Switch, choisissez **Claude Desktop**, cliquez sur **Ajouter le fournisseur**, puis sélectionnez **Configuration personnalisée**. Sélectionnez bien Claude Desktop, pas Claude Code.

![Ajout d’un fournisseur personnalisé Claude Desktop dans CC Switch](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. Renseigner la connexion et les correspondances de modèles

Dans la configuration personnalisée, renseignez \:

| Champ              | Valeur                                                   |
| ------------------ | -------------------------------------------------------- |
| Nom                | `SimiRouter`, ou un nom de votre choix                   |
| API Key            | La clé API SimiRouter copiée précédemment                |
| Adresse de requête | `https://api.dwchainless.com`, sans ajouter `/` ou `/v1` |
| Mode d’intégration | Choisissez **Correspondance de modèles**                 |
| Format amont       | Choisissez **Anthropic Messages (natif)**                |

Dans la section **Correspondance de modèles**, renseignez pour chaque rôle le nom du menu et le modèle réellement demandé. Exemple \:

| Rôle du modèle | Nom affiché dans le menu | Modèle réellement demandé |
| -------------- | ------------------------ | ------------------------- |
| Sonnet         | `claude-sonnet-5-5`      | `gpt-6-astra`             |
| Opus           | `claude-opus-5-5`        | `gpt-6-astra`             |
| Haiku          | `claude-haiku-5-5`       | `gpt-6.1-sol`             |

**Le nom du menu est seulement un libellé Claude Desktop ; le modèle appelé est celui de la colonne « Modèle réellement demandé ».** Par exemple, en choisissant l’entrée affichée `claude-sonnet-5-5`, la requête de l’exemple utilise `gpt-6-astra`, et non Claude Sonnet. Remplacez-le par l’ID exact d’un modèle accessible sur SimiRouter. Le nom affiché peut être personnalisé ; les rôles disponibles varient selon la version.

Dans la capture, l’option `1M` déclare au client une capacité de contexte ; **ne la recopiez pas simplement parce qu’elle est cochée dans l’exemple**. Cochez-la seulement si le modèle et l’interface la prennent en charge. Cliquez ensuite sur **Ajouter**.

![Correspondances CC Switch \: noms du menu et modèles réels dans deux colonnes](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

La clé API est masquée dans la capture ; renseignez votre propre clé.

### 3. Vérifier et activer le routage

1. Revenez à la liste et cliquez à droite de la carte SimiRouter sur **… → Tester la connexion** pour consulter le résultat.
2. Si le test réussit, cliquez sur le bouton d’activation (▶) à droite de la carte et suivez les indications pour activer le routage. Le statut **Routage actif** indique que ce fournisseur est sélectionné.
3. Laissez CC Switch et son routeur local en fonctionnement. Après un changement de route ou de correspondance, quittez complètement Claude Desktop, puis rouvrez-le pour recharger la configuration.

![Test de connexion dans le menu du fournisseur](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![Fournisseur SimiRouter avec routage actif](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. Activer le mode développeur de Claude Desktop

Ouvrez **Claude Desktop pour ordinateur**, puis choisissez dans le menu supérieur **Help → Troubleshooting → Enable Developer Mode**. Ignorez cette étape si ce mode est déjà activé.

![Activation du mode développeur dans le menu Help](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. Vérifier la configuration d’inférence CC Switch

1. Cliquez sur le menu du compte en bas à gauche de Claude Desktop et choisissez **Inference configuration** pour ouvrir **Configure third-party inference**.
2. Vérifiez que la liste de configuration en haut à droite sélectionne **CC Switch**. S’il y a plusieurs configurations, choisissez CC Switch. Le statut **applied** indique qu’elle est appliquée. Si des changements sont en attente, cliquez sur **Apply Changes**.
3. Dans **Connection**, cliquez sur **Test Connection**. Après la confirmation verte, fermez la fenêtre.

![Ouverture d’Inference configuration depuis le menu du compte](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![Configuration tierce CC Switch sélectionnée et appliquée](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

La clé de passerelle est masquée dans la capture. Conservez la valeur configurée par CC Switch et ne l’effacez pas.

<Callout type="info" title="">
  L’adresse de passerelle CC Switch pointe vers le routeur local et diffère de l’adresse SimiRouter saisie à l’étape 2. Il n’est normalement pas nécessaire de modifier l’adresse ou la clé de passerelle. Un test réussi ne remplace pas un véritable appel au modèle.
</Callout>

### 6. Choisir le modèle et vérifier

1. Créez une conversation, puis choisissez dans le menu près de la saisie le **Nom affiché dans le menu** configuré précédemment et envoyez un bref message. Un appel réel peut être facturé.
2. Après la réponse, consultez les appels de la console SimiRouter pour vérifier l’heure, le **modèle réel** et la consommation. L’identité annoncée par le modèle et le nom affiché dans Claude Desktop ne prouvent pas le modèle réellement appelé.

## Questions fréquentes

### Claude Desktop ou mode développeur introuvable

* Utilisez une version récente de CC Switch compatible avec Claude Desktop et sélectionnez à gauche **Claude Desktop**.
* Dans Claude Desktop, ouvrez **Help → Troubleshooting** et choisissez **Enable Developer Mode**. Si l’entrée est absente, essayez une mise à jour.

### Configuration CC Switch absente ou modèle non actualisé

* Vérifiez que la carte SimiRouter affiche **Routage actif** et laissez CC Switch ainsi que le routeur local en fonctionnement.
* Quittez complètement Claude Desktop, rouvrez-le, puis vérifiez en bas à gauche **Inference configuration**. Certaines versions permettent aussi d’utiliser **Developer → Configure third-party inference** pour ouvrir cette page.
* Vérifiez que le nom du menu est renseigné dans la correspondance et que la configuration **CC Switch** est sélectionnée. Redémarrez Claude Desktop après un changement de correspondance ou de fournisseur.

### Échec du test ou erreur de conversation

* Vérifiez que la clé CC Switch est complète et valide et que l’adresse est `https://api.dwchainless.com`.
* Vérifiez que le format amont choisi est **Anthropic Messages (natif)**, puis contrôlez le réseau et le routeur local.
* Vérifiez l’ID du modèle réellement demandé, le groupe de la clé et les autorisations, pas seulement le nom affiché.
* Utilisez le message d’erreur pour vérifier le crédit et la compatibilité. Un test de connexion réussi ne garantit pas toutes les fonctions ni tous les modèles.

## Autres méthodes de configuration

### Facultatif \: ancienne configuration directe

Les anciennes étapes directes sont conservées ci-dessous, sans nouvelle validation sur la version actuelle. Les champs et l’interface peuvent avoir changé. Si CC Switch est déjà configuré, ne répétez pas ces étapes. La disponibilité dépend de la prise en charge réelle du client.

Dans **Help → Troubleshooting**, activez d’abord le mode développeur, puis \:

1. Dans la barre de menus, sélectionnez **Developer → Configure third-party inference**.
2. Renseignez les champs du tableau suivant \:

| Champ                 | Valeur                                                                                                    |
| --------------------- | --------------------------------------------------------------------------------------------------------- |
| Base URL              | `https://api.dwchainless.com`                                                                             |
| API Key               | Votre clé API SimiRouter, par exemple `sk-...`                                                            |
| Authentication method | Choisissez `x-api-key`                                                                                    |
| Provider / API format | Si cette option apparaît, sélectionnez `Anthropic-compatible`, `custom gateway` ou une option équivalente |

<Callout type="warn" title="">
  Dans Claude Desktop, définissez Base URL sur `https://api.dwchainless.com`. Il s’agit de l’adresse de configuration de l’inférence tierce pour Claude Desktop \: ne copiez pas ici la définition de la variable `ANTHROPIC_BASE_URL` du guide Claude CLI.
</Callout>

3. Choisissez **Apply locally** pour enregistrer la configuration sur cet ordinateur.
4. Suivez les instructions du client pour vous connecter ou démarrer Claude Desktop.

## Références officielles

* [CC Switch \: configuration de Claude Desktop](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs \: configurer Claude Cowork avec une plateforme tierce](https\://claude.com/docs/third-party/claude-desktop/overview)