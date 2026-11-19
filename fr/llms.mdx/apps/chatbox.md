# Configuration de Chatbox AI

Ce guide utilise l’interface de bureau Chatbox AI 1.21.1 et le fournisseur intégré **OpenAI** pour connecter SimiRouter. Les noms et emplacements peuvent changer selon la version ; les captures illustrent l’interface chinoise.

<Callout type="warn" title="Protéger la clé API">
  Une clé API autorise les appels \: ne la partagez pas et ne l’affichez pas dans des captures publiques. Les tests de connexion et conversations peuvent être facturés ; vérifiez d’abord le crédit et les tarifs.
</Callout>

## Prérequis

1. Depuis [Site officiel de Chatbox AI](https\://chatboxai.app/) téléchargez et installez le client.
2. Connectez-vous à SimiRouter et ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) pour créer ou copier une clé. Vérifiez les autorisations et le crédit nécessaires au modèle.

![Gestion des clés SimiRouter avec les secrets masqués](/simidoc/assets/chatbox/03a-create-api-key.png)

## Configurer la connexion

### 1. Ouvrir les paramètres et choisir le fournisseur

Dans Chatbox, cliquez en bas à gauche sur **Paramètres**.

![Ouverture des paramètres Chatbox](/simidoc/assets/chatbox/01-open-settings.png)

Ouvrez **Fournisseur de modèles**, puis choisissez **OpenAI**. Ce guide utilise une clé API, sans connexion OAuth. Cette action modifie le fournisseur OpenAI ; si vous l’utilisez déjà pour un autre service, notez sa configuration afin de ne pas l’écraser.

![Sélection du fournisseur OpenAI dans Chatbox](/simidoc/assets/chatbox/02-select-openai.png)

### 2. Saisir la clé API et l’hôte

| Paramètre                      | Valeur                                            |
| ------------------------------ | ------------------------------------------------- |
| Clé API                        | Collez la clé SimiRouter copiée précédemment      |
| Hôte API                       | `https://api.dwchainless.com`                     |
| Aperçu de l’adresse de requête | `https://api.dwchainless.com/v1/chat/completions` |

Renseignez l’hôte indiqué et conservez le chemin API par défaut. N’ajoutez pas ce chemin à l’hôte. Si vous aviez personnalisé le chemin, restaurez sa valeur par défaut et vérifiez l’aperçu.

![Saisie de la clé et de l’hôte du fournisseur OpenAI](/simidoc/assets/chatbox/03b-fill-api-fields.png)

### 3. Récupérer et ajouter des modèles

Dans la section des modèles, cliquez sur **Récupérer**, recherchez le modèle, puis cliquez sur **+** à sa droite pour l’ajouter. Si la récupération échoue, utilisez **Créer** et saisissez l’ID exact d’un modèle accessible au compte. La liste ne garantit pas l’accès avec cette clé \: vérifiez les autorisations et le catalogue.

![Recherche et ajout d’un modèle](/simidoc/assets/chatbox/04-add-models.png)

### 4. Vérifier la connexion et démarrer une conversation

Pour le modèle souhaité, cliquez sur **Vérifier**. Même si le test indique « Connexion réussie », envoyez un bref message pour vérifier une vraie conversation. Certains modèles ne prennent en charge que le texte ; un échec d’image ou d’outil ne signifie pas forcément que le texte est indisponible.

![Résultat du test de connexion d’un modèle](/simidoc/assets/chatbox/05-check-success.png)

Fermez les paramètres, cliquez sur **Nouvelle conversation**, choisissez le modèle ajouté dans le groupe OpenAI du sélecteur près de la zone de saisie, puis envoyez un bref message. Après la réponse, vérifiez la requête et le modèle réel dans les journaux SimiRouter.

![Nouvelle conversation et sélection du modèle ajouté](/simidoc/assets/chatbox/06-new-chat-select-model.png)

## Questions fréquentes

* **Échec de récupération des modèles \:** vérifiez le réseau, l’hôte et la clé ; vous pouvez aussi ajouter un modèle avec son ID exact.
* **Erreur 401 ou échec d’authentification \:** vérifiez que la clé est complète, valide et sans espaces superflus ; recréez-la au besoin.
* **Erreur 404 ou chemin incorrect \:** vérifiez l’aperçu de l’URL et restaurez le chemin API par défaut pour éviter de l’ajouter deux fois.
* **Modèle introuvable ou conversation impossible \:** vérifiez l’ID réel du modèle, les autorisations et le crédit ; assurez-vous que le bon modèle est sélectionné.
* **Échec d’image ou d’appel d’outil \:** vérifiez les capacités du modèle et de l’interface ; si seul le texte est nécessaire, testez-le séparément.

Référence \: [Gestion de l’adresse et du chemin OpenAI dans Chatbox](https\://github.com/chatboxai/chatbox/blob/main/src/shared/utils/llm_utils.ts).