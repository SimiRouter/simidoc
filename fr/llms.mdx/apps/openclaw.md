# Configuration d’OpenClaw

## Prérequis

1. OpenClaw est installé et peut démarrer normalement.
2. Une clé API valide a été créée dans la console SimiRouter.
3. CC Switch est installé.

<Callout type="info" title="">
  Si CC Switch n’est pas installé, consultez d’abord [Installation et import CC Switch](/simidoc/fr/apps/cc-switch).
</Callout>

## Configurer OpenClaw dans CC Switch

1. Dans CC Switch, choisissez dans la liste des applications à gauche **OpenClaw** ; les anciennes versions utilisent les onglets supérieurs.

![Sélection d’OpenClaw dans CC Switch](/simidoc/assets/cc/cc1.png)

2. Cliquez sur **Ajouter** pour ajouter un fournisseur personnalisé.

![Ajout du fournisseur et saisie de ses paramètres](/simidoc/assets/cc/cc2.png)

3. Après l’enregistrement, vérifiez l’activation du fournisseur. Exécutez dans le terminal `openclaw onboard` et suivez l’initialisation et l’association d’OpenClaw.

![Enregistrement et activation du fournisseur](/simidoc/assets/cc/cc4.png)

4. Envoyez un bref message, vérifiez la réponse, puis l’appel dans SimiRouter. La présence d’un écran de configuration ou d’un cadre rouge ne prouve pas l’intégration du modèle.
   ![Enregistrement et activation du fournisseur](/simidoc/assets/cc/cc3.png)

## Questions fréquentes

* `baseUrl` sans `/v1` \: cause fréquente d’absence de liste des modèles.
* ID de modèle différent \: utilisez exactement le nom exposé par le service.
* Authentification ou disponibilité toujours en échec \: vérifiez que la clé et le fournisseur utilisent le même environnement.
* Pour plus de détails, lancez le service au premier plan avec `openclaw gateway --port 18789` et consultez les journaux de démarrage.

## Références officielles

[Projet officiel de CC Switch](https\://github.com/farion1231/cc-switch).