# Configuration d’Hermes

## Prérequis

1. Hermes est installé et peut démarrer normalement.
2. Une clé API valide a été créée dans la console SimiRouter.
3. CC Switch est installé.

<Callout type="info" title="">
  Si CC Switch n’est pas installé, consultez d’abord [Installation et import CC Switch](/simidoc/fr/apps/cc-switch).
</Callout>

## Configurer Hermes dans CC Switch

1. Dans CC Switch, choisissez dans la liste des applications à gauche **Hermes** ; les anciennes versions utilisent les onglets supérieurs.

![Sélection d’Hermes dans CC Switch](/simidoc/assets/hermers/h1.png)

2. Cliquez sur **Ajouter**, ajoutez un fournisseur personnalisé, puis revenez à l’onglet Hermes et activez-le.

![Ajout du fournisseur et saisie de ses paramètres](/simidoc/assets/hermers/h2.png)

3. Ouvrez le terminal et saisissez `hermes desktop` pour démarrer l’application, puis envoyez un bref message de test.`--skip-build` convient uniquement à un environnement de développement ayant déjà produit une compilation de bureau, pas au premier lancement.

![Enregistrement et activation du fournisseur](/simidoc/assets/hermers/h4.png)

4. Vous pouvez également exécuter dans le terminal `hermes --tui` pour le mode TUI. Envoyez un bref message et vérifiez l’appel dans SimiRouter ; l’affichage du TUI ne prouve pas la connexion du modèle.

![Enregistrement et activation du fournisseur](/simidoc/assets/hermers/h5.png)

## Questions fréquentes

* `baseUrl` sans `/v1` \: cause fréquente d’absence de liste des modèles.
* ID de modèle différent \: utilisez exactement le nom exposé par le service.
* Authentification ou disponibilité toujours en échec \: vérifiez que la clé et le fournisseur utilisent le même environnement.

## Références officielles

[Référence CLI du bureau Hermes](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop).