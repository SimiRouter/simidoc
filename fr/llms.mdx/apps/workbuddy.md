# Guide WorkBuddy

<Callout type="info" title="Périmètre">
  Ce guide s’applique aux clients de bureau WorkBuddy proposant « Configurer des modèles personnalisés ». Les entrées et options peuvent varier selon la version ; fiez-vous à l’interface actuelle.
</Callout>

## Prérequis

Avant de configurer, vérifiez les points suivants \:

* WorkBuddy est installé, lancé et propose l’entrée de configuration des modèles personnalisés.
* Votre compte SimiRouter existe et une clé a été créée dans la console.
* L’ID complet du modèle est connu ; la clé dispose de son autorisation et du crédit nécessaire.

[Gérer les clés API](https\://api.dwchainless.com/keys)

## Configuration

### 1. Ouvrir la configuration des modèles personnalisés

Dans WorkBuddy, cliquez sur le nom du modèle en bas à droite de la saisie, puis choisissez **« Configurer des modèles personnalisés »**.

![Ouverture de la configuration depuis la liste des modèles](/simidoc/assets/workbuddy/open-custom-model.png)

Dans la gestion des modèles, cliquez sur **« Ajouter un modèle »**. Si cette fenêtre est déjà ouverte, passez à l’étape suivante.

### 2. Choisir le fournisseur personnalisé

Dans la fenêtre d’ajout, déroulez **« Fournisseur »**, descendez jusqu’à la catégorie Autres et choisissez **« Personnalisé »**.

![Sélection du fournisseur personnalisé dans la catégorie Autres](/simidoc/assets/workbuddy/select-custom-provider.png)

Vérifiez ensuite que le champ Fournisseur affiche **« Personnalisé »**.

### 3. Saisir l’adresse API, la clé et le nom du modèle

Renseignez les informations de base \:

| Paramètre     | Valeur                                            |
| ------------- | ------------------------------------------------- |
| Fournisseur   | Personnalisé                                      |
| Adresse API   | `https://api.dwchainless.com/v1/chat/completions` |
| API Key       | Clé API créée sur SimiRouter                      |
| Nom du modèle | ID complet du modèle à appeler                    |

**Adresse API \:** copiez toute l’adresse ci-dessus, en conservant le suffixe `/v1/chat/completions`.

\*\*API Key \: \*\* collez seulement la clé, sans ajouter `Bearer`, guillemets ni commentaire, et supprimez les espaces au début ou à la fin.

**Nom du modèle \:** copiez l’ID complet depuis le catalogue SimiRouter accessible, pas une description, un surnom ou un nom de famille incomplet. Vérifiez que la clé peut appeler ce modèle.

### 4. Régler les options avancées

Pour la première configuration, conservez les valeurs d’entrée et de sortie par défaut ; adaptez les autres options aux capacités du modèle et du canal.

| Paramètre                             | Recommandation                                                                                                                 |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Appels d’outils                       | À activer si nécessaire et si le modèle ainsi que le canal prennent en charge les outils.                                      |
| Entrée image                          | À activer pour traiter des images lorsque le modèle et le canal les acceptent.                                                 |
| Mode de raisonnement                  | Suivez les indications du modèle ; vous pouvez le laisser désactivé au premier essai.                                          |
| Protocole personnalisé                | Laissez désactivé en l’absence d’exigence explicite.                                                                           |
| Effort de raisonnement, si disponible | Conservez d’abord la valeur par défaut et modifiez-la seulement pour un besoin précis.                                         |
| Entrée / Sortie                       | Conservez d’abord les valeurs du fournisseur. Avant un réglage manuel, vérifiez les limites de longueur du modèle et du canal. |

![Formulaire du modèle personnalisé \: adresse, clé, nom et options avancées](/simidoc/assets/workbuddy/custom-model-form.png)

*La capture montre les champs de l’interface chinoise. Renseignez votre propre clé et l’ID réel du modèle selon les explications.*

### 5. Tester, enregistrer et sélectionner le modèle

Une fois les champs renseignés, cliquez sur **« Tester la connexion »** pour contrôler la connexion, puis sur **« Enregistrer »**. Si le test échoue, consultez les questions fréquentes ci-dessous.

Revenez à la conversation WorkBuddy, ouvrez la liste des modèles en bas à droite, **sélectionnez le modèle personnalisé ajouté**, puis envoyez un bref message, par exemple \:

```text
请只回复：连接成功。
```

Après une réponse normale, consultez les appels à l’heure correspondante dans SimiRouter pour vérifier le modèle demandé.

Lorsque le dialogue de base fonctionne, testez séparément les outils, les images et le raisonnement nécessaires.

## Questions fréquentes

En cas de problème, lisez d’abord l’erreur complète, puis utilisez le tableau suivant.

| Problème                                                       | Diagnostic                                                                                                         |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Configuration des modèles personnalisés introuvable            | Vérifiez que cette version du client offre la fonction et que la liste des modèles près de la saisie est ouverte.  |
| Échec du test ou de l’envoi de messages                        | À partir de l’erreur, vérifiez l’adresse, la clé, l’ID du modèle, les autorisations et le crédit.                  |
| Configuration enregistrée, mais ancien modèle toujours utilisé | Revenez à la conversation et sélectionnez le modèle personnalisé enregistré.                                       |
| Échec après activation des images ou du raisonnement           | Restaurez le dernier réglage fonctionnel, puis vérifiez la prise en charge par le modèle et le canal.              |
| Erreur avec une longue conversation ou sortie                  | Vérifiez les limites du modèle et du canal ; raccourcissez l’entrée ou réduisez la sortie maximale selon l’erreur. |

Pour obtenir de l’aide, indiquez **la version WorkBuddy, l’ID du modèle, l’heure et l’erreur complète**.

<Callout type="warn" title="Sécurité des clés">
  Protégez votre clé API. Masquez-la entièrement avant de transmettre une capture, un journal ou une erreur ; ne la publiez pas.
</Callout>

## Références officielles

[Modèles personnalisés WorkBuddy](https\://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Model).