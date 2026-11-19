# Créer une clé SimiRouter

Ce guide explique l’inscription, la connexion, la création d’une clé et le premier appel. Si vous possédez déjà un compte, connectez-vous directement. Les clients et paramètres API ont leurs propres pages.

## 1. S’inscrire ou se connecter à SimiRouter

Ouvrez [Page d’inscription](https://api.dwchainless.com/sign-up) pour créer un compte ; si vous en avez déjà un, utilisez [Se connecter](https://api.dwchainless.com/sign-in). Les méthodes d’inscription et leur disponibilité dépendent de la page actuelle.

Connectez-vous et ouvrez [Portefeuille](https://api.dwchainless.com/wallet) et vérifiez le crédit disponible ainsi que les autorisations du groupe et de la clé pour le modèle. Pour recharger ou utiliser un code, suivez les indications de la page Portefeuille ; les offres, crédits et durées de validité y sont affichés. Ne payez pas deux fois.

## 2. Créer une clé API

Ouvrez [Gestion des clés API](https://api.dwchainless.com/keys), puis choisissez Créer une clé. Définissez le groupe, les modèles, le quota et la validité selon vos besoins. Consultez l’aide des options incertaines avant d’enregistrer et copier la clé.

![Gestion des clés API et entrée de création](/simidoc/assets/start/start5.png)

<Callout type="warn" title="Protéger la clé">
  Une clé API représente une autorisation d’appel. Ne l’exposez pas dans un dépôt, une capture ou un journal public et ne la donnez pas à une application non fiable. Révoquez-la immédiatement en cas de fuite présumée.
</Callout>

## 3. Distinguer les trois informations de connexion

| Information            | Utilité                                 | Attention                                                                                                              |
| ---------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Adresse API / Base URL | Détermine le destinataire de la requête | Suivez le guide du client \: certains exigent `/v1`, d’autres seulement la racine ; n’ajoutez pas le chemin deux fois. |
| API Key                | Authentifie l’autorisation d’appel      | Utilisez la clé créée, pas le mot de passe du compte.                                                                  |
| Nom du modèle          | Choisit le modèle à appeler             | Dans [Place des modèles](https://api.dwchainless.com/fr/pricing/) copiez l’ID complet. Le nom, le groupe et les autorisations doivent correspondre.   |

L’adresse, la clé et le modèle sont trois champs distincts ; ne placez pas la clé dans l’URL.

## 4. Choisir votre client

* [Application de bureau Codex](/simidoc/fr/apps/codex-desktop) \: travail de développement sur ordinateur.
* [Codex CLI](/simidoc/fr/apps/installation/codex-cli) \: installation et connexion en ligne de commande.
* [Claude Code](/simidoc/fr/apps/installation/claude-code) \: installation, environnement et utilisation.
* [WorkBuddy](/simidoc/fr/apps/workbuddy) \: connexion de modèles personnalisés sur ordinateur.
* [Scripts API](/simidoc/fr/apps/api-script) \: intégrer votre programme à partir d’exemples de requêtes.

Les champs et protocoles varient selon le client. Suivez son guide ; ne réutilisez pas directement le fichier de configuration d’un autre client.

## 5. Tester à petite échelle et vérifier les traces

Après l’enregistrement, envoyez une courte requête, puis ouvrez [Journaux d’utilisation](https://api.dwchainless.com/usage-logs/common) pour vérifier l’heure, le modèle, le statut et la consommation. Les super-administrateurs voient les journaux globaux ; les administrateurs voient leurs propres requêtes, recharges, opérations d’administration et erreurs ; les utilisateurs standard voient leurs propres requêtes, recharges et opérations d’administration, mais pas les erreurs. Pour les tendances agrégées, consultez [Tableau de bord](https://api.dwchainless.com/dashboard).

Une réponse prouve uniquement qu’une requête a produit un résultat, pas son routage réel. En cas d’échec, vérifiez l’adresse, la clé, l’ID complet et le groupe, puis utilisez l’erreur et l’ID de requête. Fournissez au support des informations expurgées, sans clé.