# Droits des journaux d’utilisation et d’audit

Ce guide explique la visibilité selon le rôle dans les journaux d’utilisation et d’audit, ainsi que la façon d’identifier le canal qui a réellement traité une requête.

## Journaux d’utilisation

### Super administrateurs

Les super administrateurs peuvent consulter les journaux complets de tous les utilisateurs. Dans les [journaux d’utilisation](https://api.dwchainless.com/usage-logs/common), choisissez **Erreurs uniquement** dans le filtre de type pour afficher les appels en erreur de tous les utilisateurs. Le filtre conserve les erreurs survenues pendant les tentatives, même si la requête finale a réussi.

La colonne du canal indique le canal qui a réellement traité la requête. Pour analyser le routage, utilisez le canal, le modèle, le statut et l’identifiant de requête présents dans le journal, plutôt que le seul nom de modèle affiché par le client.

### Administrateurs

Les administrateurs ne peuvent consulter que leurs propres journaux de requêtes, de recharge, d’opérations d’administration et d’appels en erreur. Les paramètres de nom d’utilisateur, de rôle et d’URL ne peuvent pas élargir ce périmètre. Ils ne disposent pas d’un filtre global **Erreurs uniquement**, mais leurs propres erreurs restent visibles selon leurs droits.

### Utilisateurs standard

Les utilisateurs standard ne peuvent consulter que leurs propres journaux de requêtes, de recharge et d’opérations d’administration. Ils ne peuvent pas consulter les journaux d’erreurs ni ceux d’un autre utilisateur.

## Journaux d’audit

Les super administrateurs peuvent consulter les événements d’audit de tous les utilisateurs et filtrer par nom d’utilisateur. Les administrateurs et les utilisateurs standard sont limités aux événements du compte actuellement authentifié ; les paramètres de page ne peuvent pas élargir ce périmètre côté serveur.

## Mises à jour du statut des canaux

L’événement d’audit `channel.status_update` signifie **mise à jour du statut du canal**. Il enregistre une opération manuelle sur un seul canal. Le code actuel accepte le statut cible activé ou désactivé manuellement ; `changed=false` signifie que la requête a réussi sans modifier l’état du canal. Les opérations groupées utilisent `channel.status_update_batch`. Consultez les détails de l’événement, l’opérateur et l’heure pour connaître l’opération précise.

## Dépannage

1. Confirmez la période et l’identifiant de requête.
2. Pour une recherche globale d’erreurs, un super administrateur doit choisir **Erreurs uniquement**.
3. Vérifiez le canal, le modèle et le statut réels au lieu de vous fier uniquement au libellé du client.
4. Pour les délais d’attente, les réponses 5xx ou les flux interrompus, consultez les journaux et l’identifiant de requête avant de réessayer afin d’éviter une double facturation.