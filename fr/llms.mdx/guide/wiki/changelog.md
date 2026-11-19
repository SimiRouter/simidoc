# Historique des modifications

<Callout type="warn" title="Historique des versions · données actualisées le 12 août 2026 à 18:48:26">
  Pour toutes les versions, consultez [GitHub Releases](https\://github.com/QuantumNous/new-api/releases). Cette page n’est pas actualisée en temps réel ; la dernière synchronisation figure dans le titre de cet encadré. Si les publications amont sont plus récentes, elles font foi.
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="Dernier enregistrement de cette page · publié le 7 août 2026 à 17:47:48, heure de Chine">
  ### Version \: v1.0.0-rc.24

  #### Nouveautés

  * Ajout d’un middleware limitant les opérations utilisateur critiques sur les routes de jetons d’accès et de transfert de commissions pour renforcer sécurité et stabilité.
  * Catégorisation des modèles récupérés dans les canaux affinée pour faciliter leur organisation et leur recherche.

  #### Corrections

  * Correction de la perte de précision du crédit des codes d’échange, afin d’attribuer le bon montant (#6685).
  * Correction d’un problème HTTP/2 empêchant les reprises transparentes après réinitialisation du flux amont, en définissant correctement `Request.GetBody` dans le relais (#6249).
  * Les tests des points d’accès Claude et Gemini utilisent désormais leur format natif pour une meilleure compatibilité.

  #### Autres

  * Amélioration du workflow de synchronisation des versions avec synchronisation facultative des fichiers en CI.

  ***

  ### Modifications

  * fix(relay) \: définir Request.GetBody pour permettre les reprises transparentes HTTP/2 après réinitialisation amont — par @BlockchainHe dans [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels) \: affiner la catégorisation des modèles récupérés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix \: tester Claude/Gemini avec leur format de requête natif — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix \: perte de précision du crédit des codes corrigée (#6680), par @lihu-001 dans [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### Nouveaux contributeurs

  * @BlockchainHe a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="Version stable · publiée le 1er août 2026 à 23:25:04, heure de Chine">
  Points clés \: compatibilité étendue avec les canaux New API, DeepSeek Responses API, décompression zstd et routage automatique des groupes. Les journaux indiquent le streaming ; la facturation des reprises par paliers est plus fiable et les requêtes Bedrock amont sont annulées à la déconnexion du client.

  ### Nouveautés

  * Ajout des canaux New API avec conversion streaming Gemini vers OpenAI, traitement Advanced Custom Responses Compact et édition d’images multipart (#6559).
  * Ajout de DeepSeek Responses API (#6562).
  * Ajout de la sélection automatique du groupe de routage (#6590).
  * Ajout de contrôles HTTP par canal pour régler le comportement des connexions.
  * Ajout des requêtes compressées en zstd (#6545).
  * Les propriétaires des journaux peuvent voir si la requête utilisait le streaming (#6558).

  ### Corrections

  * Qwen `thinking_budget` est désormais conservé lors du relais des requêtes (#5836).
  * La facturation des reprises par paliers utilise le groupe final choisi, y compris après un changement de groupe (#6570).
  * Les requêtes Bedrock sont annulées à la déconnexion du client pour réduire le travail amont inutile (#6589).

  ### Améliorations

  * Les liens de navigation publique utilisent une taille de police uniforme (#6557).

  ***

  ### Modifications

  * refactor \: extraire la conversion de protocoles dans le module autonome relaykit — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix \: paramètres des journaux de requêtes lentes et erreurs SQL, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc) \: nom de connexion OIDC personnalisé, par @mrchi dans [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix \: conserver la transmission de thinking\_budget de Qwen — par @wxwwt dans [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat \: décompresser les requêtes zstd — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs) \: montrer le streaming aux propriétaires des journaux — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay) \: conserver les éditions multipart des canaux New API — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth) \: ne plus traiter un window\.opener étranger comme une association — par @neimaravila dans [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style \: uniformiser la navigation publique à 14px (text-sm) — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat \: API Responses DeepSeek — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing) \: régler les reprises par paliers selon le groupe final — par @faithleysath dans [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing) \: renforcer la facturation après changement de groupe (suite de #6518) — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws) \: annuler Bedrock à la déconnexion du client — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * Fonction \: groupe automatique — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### Nouveaux contributeurs

  * @mrchi a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="Version stable · publiée le 26 juillet 2026 à 21:19:04, heure de Chine">
  Gestion étendue des canaux et modèles \: découverte amont, nouveaux modèles d’image Gemini, facturation configurable et Sub2API. Fiabilité améliorée du streaming, des tarifs, remboursements, utilisateurs et workflows administrateur.

  ### Nouveautés

  * Les canaux découvrent les modèles disponibles auprès des amonts personnalisés avancés et compatibles Codex (#6184).
  * Ajout des derniers modèles d’image Gemini en disponibilité générale (#6371).
  * Ajout des tarifs d’outils configurables avec canaux Sub2API et facturation alpha-search.
  * Ajout des modèles OpenAI Realtime GA et amélioration du routage (#6032).

  ### Corrections

  * Le streaming Responses vers Chat ne duplique plus les appels d’outils (#6225).
  * Créer un modèle de même nom n’efface plus ses tarifs enregistrés (#6365).
  * La vue des modèles sans tarif ne montre que ceux disponibles dans les canaux sélectionnés (#6126).
  * Les quotas utilisateur très élevés sont traités sans dépassement numérique (#6134).
  * Le tri des utilisateurs fonctionne avec les résultats paginés (#6194).
  * Les modèles MiniMax sont correctement associés au fournisseur MiniMax (#6164).
  * Les sélecteurs de groupes Playground gèrent les listes automatiques et les longues options (#6163).
  * Les mises à jour d’état concurrentes ne dupliquent plus les remboursements de tâches (#6074).
  * Les champs de montant de recharge peuvent être entièrement vidés (#6473).
  * La modification directe des priorités de canal est plus fiable (#6415).

  ### Améliorations

  * Édition JSON administrateur uniformisée, sans problèmes d’interface masquant le contenu (#6421).
  * La recherche d’utilisateurs est temporisée pour réduire les requêtes et améliorer la réactivité (#6474).
  * Les requêtes de canal via proxy sont plus compatibles et stables (#6157).
  * Les journaux amont donnent de meilleurs détails de secours quand le fournisseur renvoie une erreur imprécise (#6431).

  ***

  ### Modifications

  * fix \: limiter les modèles sans tarif à ceux des canaux — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix \: supprimer les données d’authentification lors d’une suppression définitive d’utilisateur — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users) \: éviter le dépassement des grands quotas — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix \: reconnaître le fournisseur des modèles MiniMax — par @fux-dev dans [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix \: trier les utilisateurs côté serveur, pas seulement la page cliente — par @DawnMoon1542 dans [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table) \: actualiser immédiatement le tableau au changement de colonnes — par @DawnMoon1542 dans [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix \: éviter les appels d’outils doublés dans Responses vers Chat — par @nikuleo dans [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel) \: découvrir les modèles amont Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat \: récupérer les modèles amont des canaux personnalisés avancés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth) \: remplacer les sessions de tableau de bord par des jetons sans état et un contrôle de session — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix \: suppression de l’en-tête bêta Realtime pour les modèles GA gpt-realtime relayés, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground) \: éviter l’étirement des options de groupe — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table) \: optimiser la largeur de la colonne d’actions — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web) \: montrer le quota consommé des clés illimitées — par @RedwindA dans [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel) \: améliorer la compatibilité proxy et le cycle de vie du cache — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground) \: corriger la liste des modèles de groupe automatique — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix \: éviter les remboursements Suno doublés grâce à une mise à jour CAS — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github) \: migrer les modèles de tickets vers des formulaires obligatoires — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github) \: restaurer la visibilité des formulaires de tickets — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix \: journaliser le corps si le message d’erreur amont analysé est vide — par @bigsongeth dans [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix \: ne pas effacer les tarifs existants en créant un modèle de même nom — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel) \: stabiliser la modification directe des priorités — par @RedwindA dans [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor) \: uniformiser l’édition JSON administrateur — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat \: ajouter gemini-3-pro-image et gemini-3.1-flash-image GA — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat \: accepter les clés Tencent TokenHub via le protocole compatible OpenAI — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix \: permettre de vider entièrement le montant de recharge — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix \: temporiser la recherche d’utilisateurs — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### Nouveaux contributeurs

  * @fux-dev a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="Version stable · publiée le 11 juillet 2026 à 23:01:26, heure de Chine">
  ### Points clés

  Le changement principal concerne les écritures de cache GPT-5.6 \: les tokens OpenAI `cache_write_tokens` sont facturés au tarif de création du cache, avec protection du décompte des tokens d’entrée mis en cache ou non. Améliorations aussi des tarifs, commandes Playground, tableaux de canaux, facturation et journaux.

  ### Nouveautés

  * Ajout de la facturation des écritures de cache GPT-5.6 \: les tokens OpenAI `cache_write_tokens` sont facturés au tarif de création tout en conservant un décompte cohérent des tokens d’entrée en cache et hors cache.
  * Les pages de tarifs calculent dynamiquement selon le groupe et masquent les groupes spéciaux réservés aux exemples (#5906).
  * Les tarifs de modèles incluent un onglet Sans tarif et des filtres d’état/synchronisation pour faciliter la configuration (#6124).
  * Ajout de panneaux de paramètres de conversation et de génération dans Playground (#6044).
  * Les colonnes des canaux sont redimensionnables manuellement et le tableau occupe la largeur disponible (#5948).
  * Ajout des durées de streaming et détails de tâches aux journaux pour le diagnostic.
  * Conversion textuelle et routage personnalisé avancés pour plus de souplesse (#5825).

  ### Corrections

  * La traduction du navigateur ne peut plus corrompre les pages React (#5963).
  * Les modèles dont les noms ne diffèrent que par la casse peuvent être ajoutés, y compris par sélection multiple (#6061).
  * La facturation gère mieux la préconsommation et les déconnexions de flux d’images.
  * La réinitialisation des abonnements est plus fiable en concurrence (#6057).
  * Les champs transmis des réponses Codex sont correctement synchronisés (#6018).
  * Le sélecteur Playground reste synchronisé après modification des modèles.
  * Les iframes de page d’accueil personnalisée peuvent naviguer au niveau supérieur après une action utilisateur (#5955).
  * Restauration du collage dans la configuration de connexion des canaux par défaut.

  ### Améliorations

  * Chargement et affichage plus efficaces des tableaux de synchronisation des prix amont (#6092).
  * Amélioration des badges, tarifs, dialogues de synchronisation et thème par défaut pour une interface plus claire.
  * Les polices sont correctement résolues dans les différentes structures d’espace de travail.

  ***

  ### Modifications

  * fix(web) \: empêcher la traduction du navigateur de modifier les racines React — par @cat0825 dans [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web) \: largeur manuelle des colonnes des canaux, par @zuiho-kai dans [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web) \: remplir la largeur disponible avec le tableau des canaux — par @zuiho-kai dans [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore \: retirer les fichiers morts réintroduits au lancement v1.0 — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix \: utiliser le verrouillage de lignes GORM v2 pour les réinitialisations d’abonnement — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground) \: ajouter le panneau de paramètres — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix \: autoriser en sélection multiple les noms ne différant que par la casse — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix \: retirer les groupes spéciaux d’exemple de la page de tarifs — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing) \: optimiser les tableaux de synchronisation amont — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web) \: permettre à l’iframe d’accueil la navigation supérieure après action utilisateur — par @Heykode dans [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps) \: passer golang.org/x/crypto de 0.51.0 à 0.52.0 — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix \: synchroniser les champs transmis des réponses Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat \: améliorer la conversion textuelle et le routage personnalisé avancé — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat \: ajouter l’onglet des modèles sans tarif — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### Nouveaux contributeurs

  * @cat0825 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="Version stable · publiée le 7 juillet 2026 à 21:46:39, heure de Chine">
  ### Points clés

  Ajout des tarifs GPT-5.6 et d’outils administrateur pour nettoyer les instances obsolètes. Correction de cas limites de quota et de prix, notamment transferts de récompenses du portefeuille et saisie des ratios décimaux.

  ### Nouveautés

  * Ajout de la tarification par tokens GPT-5.6.
  * Ajout d’actions system-info pour nettoyer les instances obsolètes (#5953).

  ### Corrections

  * Les transferts de récompenses respectent l’unité de quota configurée au lieu d’une constante incorrecte (#5808).
  * Les champs de ratio de groupe acceptent normalement les décimales comme `0.05` (#5995).
  * La préconsommation par paliers utilise une estimation de tokens par défaut pour mieux calculer les quotas.

  ***

  ### Modifications

  * fix \: préservation des décimales intermédiaires du ratio de groupe et saisie 0,05, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info) \: ajouter le nettoyage des instances obsolètes — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet) \: respecter l’unité de quota configurée lors des transferts de récompenses — par @A-Words dans [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### Nouveaux contributeurs

  * @A-Words a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="Version stable · publiée le 7 juillet 2026 à 14:06:07, heure de Chine">
  Correction d’une erreur d’internationalisation

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="Version stable · publiée le 7 juillet 2026 à 13:19:27, heure de Chine">
  ### Nouveautés

  * Les administrateurs peuvent réinitialiser les quotas d’abonnement et consulter leur saturation pour l’audit (#5952).
  * Ajout du chinois traditionnel zh-TW dans la nouvelle interface (#5942).

  ### Corrections

  * Correction des calculs de très grands quotas pour appliquer les limites correctement.

  ***

  ### Modifications

  * Localisation de la nouvelle interface en zh-TW — par @MeowTechOpenSource dans [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription) \: ajouter la réinitialisation des quotas par l’administrateur — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### Nouveaux contributeurs

  * @MeowTechOpenSource a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="Version stable · publiée le 7 juillet 2026 à 01:16:57, heure de Chine">
  Gestion des quotas de facturation plus fiable grâce à une validation stricte des quantités.

  **Corrections**

  * Validation des quantités améliorée pour gérer les valeurs invalides ou extrêmes dans quotas et utilisation.

  ***

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="Version stable · publiée le 6 juillet 2026 à 22:37:46, heure de Chine">
  ### Points clés

  Amélioration des tests de canaux, codes d’échange, thèmes et parcours Web. Correction des rapports d’utilisation, compilation classique, déconnexions de flux et calculs de quota/durée vidéo.

  ### Nouveautés

  * La gestion des codes d’échange propose filtrage par état et nettoyage.
  * Édition des ratios de groupe simplifiée avec affichage plus clair et JSON plus robuste.
  * Les échecs d’échange donnent des messages plus explicites.

  ### Corrections

  * Les intégrations AI Elements lisent les données d’utilisation imbriquées pour compter correctement les tokens.
  * La compilation Web classique fonctionne de nouveau (#5892).
  * Les contrôles de transmission des champs apparaissent pour les canaux Codex (#5902).
  * L’iframe d’accueil suit le thème et la langue sélectionnés (#5917).
  * Le HTML personnalisé dans Shadow DOM suit correctement les modes clair et sombre (#5890).
  * Les utilisateurs connectés sont redirigés hors de l’inscription, comme dans les thèmes de connexion et classique (#5910).
  * Les réponses en streaming n’écrivent plus après la déconnexion du client (#5710).
  * Correction du règlement des quotas et des durées vidéo Ali après le règlement du solde de tâche (#5923).
  * La génération de date de compilation ne bloque plus sur une erreur DNS (#5945).

  ### Améliorations

  * Dialogues de test de canal et modèle plus compacts et maniables (#5886).
  * Le détail des tarifs dynamiques suit le style des détails de journal (#5905).
  * Cartes utilisateur mobiles améliorées pour la lecture et la disposition.
  * Avertissement de recharge ancien plus clair (#5855).

  ***

  ### Modifications

  * chore(deps-dev) \: passer tmp de 0.2.5 à 0.2.7 dans /electron — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web) \: mettre à jour les dépendances Web par défaut — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web) \: améliorer les interactions du dialogue de test de canal — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic) \: corriger la compilation Web classique — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels) \: afficher les contrôles de transmission pour Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix \: aligner le style des tarifs dynamiques sur les détails de journal — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix \: quota après règlement différentiel et durée des vidéos Alibaba, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web) \: synchroniser thème et langue de l’iframe d’accueil — par @guoruqiang dans [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web) \: thèmes du HTML personnalisé isolé dans Shadow DOM, par @olwater dans [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web) \: garde de redirection des utilisateurs connectés à l’inscription, cohérente avec le thème classique (#5908), par @Heykode dans [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat \: clarifier l’avertissement de recharge ancien (#5851) — par @Gravirei dans [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix \: éviter les écritures de flux après déconnexion du client — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * Correction de l’erreur DNS de date de compilation — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### Nouveaux contributeurs

  * @Heykode a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="Version stable · publiée le 3 juillet 2026 à 15:41:42, heure de Chine">
  **Points clés**

  Compatibilité étendue \: interopérabilité Responses/Chat, mises à jour Doubao Seedance 2.0 et mappage multimédia Wan2.7 i2v. Améliorations Web du rendu Playground, de la gestion des canaux, conservation d’état et redémarrage propre.

  **Nouveautés**

  * Ajout de la compatibilité Responses vers Chat pour fiabiliser les échanges entre fournisseurs et clients des deux formats (#5787).
  * Extension Seedance 2.0 \: API de ressources, facturation par résolution et vidéo d’entrée, 4K et nouvelles options (#5824).
  * Ajout du mappage multimédia Wan2.7 image vers vidéo (#4984).
  * Ajout d’un arrêt propre pour limiter les réponses interrompues et pertes de cache au redémarrage (#4258).
  * Gestion des canaux plus claire avec éditeur de routage avancé amélioré.

  **Corrections**

  * L’éditeur d’expression de tarification se réactualise au changement de modèle (#5752).
  * Les journaux des tâches asynchrones attribuent l’utilisation au nœud initiateur (#5684).
  * Changer de thème revient à l’accueil au lieu d’une route 404 (#5612).
  * HTML et Markdown personnalisés conservent styles et espacements cohérents, y compris en vues isolées (#5795).
  * L’état n’est plus réinitialisé entre onglets d’une même route, notamment les périodes du tableau de bord (#5796).
  * Les filtres d’état des canaux persistent entre pages (#5863).
  * Correction des outils Ollama sans streaming (#5865).
  * Correction des informations produit Waffo et des webhooks (#5704).

  **Améliorations**

  * Amélioration de la conversation Playground et du rendu Markdown (#5217).
  * Actions de tableaux et confirmations destructives simplifiées (#5645).
  * Amélioration des filtres LIKE dans les journaux ClickHouse.
  * Pipeline de compilation frontend optimisé pour accélérer les builds Web (#5786).

  ***

  ### Modifications

  * chore(deps) \: passer dompurify de 3.4.5 à 3.4.11 dans /web/default — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci) \: installer les dépendances de l’espace classique pour les versions — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web) \: simplifier actions de tableaux et dialogues destructifs — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix \: ajouter les informations produit Waffo et mettre à jour le SDK webhook — par @zhongyuanzhao-alt dans [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing) \: actualiser l’éditeur par paliers au changement de modèle — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix \: synchroniser bun.lock avec dompurify 3.4.11 pour restaurer le build frozen-lockfile — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme) \: retour à l’accueil après changement de thème pour éviter les 404, par @zhangzhichaolove dans [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task) \: attribuer l’utilisation asynchrone au nœud initiateur — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat \: ajouter les autorisations administrateur Casbin — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground) \: améliorer conversation et Markdown — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth) \: harmoniser les messages de validation de mot de passe — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web) \: rendre HTML personnalisé et Markdown de façon cohérente — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai) \: renforcer la compatibilité Chat vers Responses — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat \: prendre en charge Responses vers Chat — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat \: facturation par résolution de doubao-seedance-2-0-260128, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat \: prendre en charge safety\_identifier/priority et facturation 4K Seedance 2.0 — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web) \: filtrage du HTML personnalisé et problèmes de mise en page, par @olwater dans [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat \: prendre en charge le mappage Wan2.7 i2v — par @wxwwt dans [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web) \: optimiser le pipeline Rsbuild et Tailwind — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile) \: lancer seulement le serveur Web par défaut avec dev-web — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web) \: injecter les styles de l’application dans le HTML isolé — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix \: conserver l’état entre onglets de même route, notamment la période du tableau de bord — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * Arrêt propre des services pour éviter les réponses interrompues et pertes de cache au redémarrage, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix \: considérer seulement 401 comme expiration de session dans le thème par défaut — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix \: conserver le filtre d’état de canal entre pages — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps) \: passer golang.org/x/net de 0.50.0 à 0.55.0 — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps) \: passer golang.org/x/image de 0.38.0 à 0.41.0 — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix \: gérer les outils Ollama sans streaming — par @stevenjoezhang dans [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### Nouveaux contributeurs

  * @zhangzhichaolove a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="Version stable · publiée le 24 juin 2026 à 21:00:04, heure de Chine">
  ### Points clés

  Ajout de contrôles d’exploitation \: surveillance passive des canaux, journaux ClickHouse, tâches système et visibilité des instances. Fiabilité et finition frontend améliorées pour journaux, Markdown, sélection de canaux et portefeuille facultatif.

  ### Nouveautés

  * Ajout d’une surveillance passive de santé des canaux sans perturber activement le trafic (#5592).
  * Ajout du stockage des journaux dans ClickHouse pour les déploiements nécessitant stockage et recherche extensibles (#5663).
  * Ajout d’un exécuteur de tâches système avec suivi persistant du nettoyage pour les maintenances longues (#5680).
  * Ajout d’un panneau d’informations d’instances pour inspecter déploiement et nœuds (#5716).
  * Ajout d’une section de limites de jetons utilisateur dans les paramètres système (#5678).
  * Ajout aux tests de canaux du choix d’environnement et du délai d’interrogation asynchrone.
  * Le nom de nœud utilise le nom de machine si `NODE_NAME` n’est pas défini (#5659).

  ### Corrections

  * Les journaux d’utilisation montrent correctement les icônes des fournisseurs CN (#5631).
  * Correction du nom affiché Stepfun (#5636).
  * Correction SMTP avec STARTTLS et authentification NTLM (#5426).
  * Correction de la compilation du thème classique liée aux fuseaux horaires (#5676).
  * Rendu Markdown amélioré et syntaxe étendue dans l’interface Web (#5689).
  * La sélection des cartes de canaux reste synchronisée avec le canal choisi (#5700).
  * L’entrée du portefeuille est masquée du profil si son module est désactivé (#5708).

  ### Améliorations

  * Nettoyage des journaux simplifié dans le nouveau fonctionnement ClickHouse et tâches système.

  ***

  ### Modifications

  * fix(usage-logs) \: afficher les icônes CN comme dans le frontend classique — par @DeliciousBuding dans [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix \: StepFun devient Stepfun — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat \: surveillance passive des canaux — par @exherb dans [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat \: utiliser le nom de machine si NODE\_NAME est absent — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat \: base ClickHouse pour les journaux — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix \: SMTP STARTTLS et authentification NTLM — par @bensonfx dans [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps) \: passer github.com/ClickHouse/ch-go de 0.58.2 à 0.65.0 — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix \: erreur de compilation classique date-fns-tz — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat \: exécuteur de tâches système — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat \: panneau d’informations des instances — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web) \: remplacer le moteur Markdown et étendre la syntaxe — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web) \: synchroniser la sélection des cartes de canaux — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web) \: masquer le portefeuille du profil si son module est désactivé — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings) \: section de limites des jetons utilisateur — par @RedwindA dans [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### Nouveaux contributeurs

  * @DeliciousBuding a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="Version stable · publiée le 20 juin 2026 à 22:15:42, heure de Chine">
  ### Points clés

  Ajout d’un diagramme Sankey du trafic pour visualiser routage et flux de tokens, avec surbrillance interactive, filtres persistants et limites pour les grands graphes. Les cartes de canaux sont plus rapides, plus claires et évitent des rendus inutiles.

  ### Nouveautés

  * Ajout du diagramme Sankey de trafic au tableau de bord pour visualiser flux et routage des tokens (#5465).
  * Ajout de la gestion de fiabilité du routage pour plus de contrôle et de visibilité.

  ### Illustrations

  | Diagramme de trafic                                                                                                              | Cartes de gestion des canaux                                                                                                   |
  | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
  | ![Exemple de disposition des cartes de canaux](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Illustration des notes de version Gallery](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### Corrections

  * Correction du filtre de type de connexion des journaux dans le nouveau frontend (#5620).
  * Correction du dialogue d’historique pour éviter le chevauchement de pagination (#5627).
  * Correction des lignes impossibles à supprimer dans la tarification visuelle (#5628).
  * Correction des migrations de colonnes répétées après redémarrage (#5361, #5616).

  ### Améliorations

  * Cartes de canaux améliorées et rendus inutiles réduits pour plus de fluidité.
  * Liste des modèles simplifiée pour faciliter lecture et gestion.
  * Icônes de canaux actualisées pour une cohérence visuelle.

  ***

  ### Modifications

  * fix \: arrêter la migration répétée de allow\_balance\_pay au redémarrage — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix \: arrêter la migration répétée de allow\_wallet\_overflow au redémarrage — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard) \: diagramme Sankey des flux de tokens, par @Quaternijkon dans [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log) \: filtrage des journaux par type de connexion type=7, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet) \: pagination et chevauchement des listes du portefeuille (#5624), par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing) \: suppression des lignes de tarification (#5623), par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### Nouveaux contributeurs

  * @Quaternijkon a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="Version stable · publiée le 19 juin 2026 à 20:28:34, heure de Chine">
  v1.0.0-rc.13 améliore la finition et la réactivité du frontend, surtout pour les canaux et pages riches en données. La page des canaux propose des cartes adaptées au mobile ; journaux, métriques, points d’accès, dates et vues d’utilisation sont améliorés.

  ### Nouveautés

  * Ajout d’une bascule réutilisable cartes/tableau, avec des cartes adaptées aux canaux et pages riches en tableaux sur différentes tailles d’écran.
  * Ajout du formatage des nombres selon la langue et la région.

  ### Améliorations

  * Cartes de canaux plus claires, structurées gauche/droite et adaptées aux petits écrans.
  * Amélioration des journaux, métriques, sélecteur de point d’accès, dates, barres d’outils et tiroirs de modèles pour une interface cohérente.
  * Interface d’utilisation Codex plus lisible et pratique (#5595).
  * Actualisations inutiles réduites au retour du focus navigateur pour améliorer les performances.
  * Textes de marque et styles frontend harmonisés.

  ### Corrections

  * Précision des dates de dessin améliorée avec millisecondes si nécessaire.

  ***

  ### Modifications

  * chore(web) \: imposer les contrôles qualité oxc au frontend par défaut — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor \: interface d’utilisation Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="Version stable · publiée le 18 juin 2026 à 20:34:16, heure de Chine">
  Points clés \: canaux AdvancedCustom pour un routage flexible, tests groupés plus exploitables et surveillance du catalogue avec taux de succès et latence plus clairs.

  ### Nouveautés

  * Ajout des canaux AdvancedCustom avec meilleure correspondance des routes de fournisseurs et modèles (#5590).
  * Tests groupés améliorés \: exécution complète, état actualisé, résultats clairs, suppression des modèles échoués et copie de la sélection (#5532).
  * Surveillance du catalogue étendue \: disponibilité, succès récents, niveaux de réussite et mesures compactes de latence/débit.
  * Préférences de tableau persistantes \: pagination et visibilité des colonnes entre pages et sessions (#5403).

  ### Corrections

  * Correction des appels d’outils \: même avec une valeur `arguments` vide, le bloc `tool_use` attendu est conservé (#5543).
  * Le sélecteur CC Switch affiche et actualise correctement les modèles (#5515).
  * Correction de troncatures et débordements dans listes, tableaux, détails de journaux et iframes d’accueil (#5510, #5536, #5533, #5545).

  ### Améliorations

  * Paiement et recharge clarifiés \: boutons, icônes et minimum de recharge.
  * Présentation des abonnements améliorée \: description d’achat, débordement du portefeuille et groupes de rétrogradation.
  * Paramètres, guide initial, portefeuille/profil et cartes de statistiques rendus plus lisibles.

  ### Changements incompatibles

  * Les points d’accès d’options et catalogue des abonnements utilisent désormais `GET`, ce qui peut imposer une mise à jour de méthode aux clients.
  * Suppression de la période « Tous » des filtres de classement.

  ***

  ### Modifications

  * fix(web) \: éviter les débordements de texte et badges des listes — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys) \: actualiser les options du formulaire de clé API — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix \: corriger le sélecteur de modèle CC Switch — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table) \: inclure la sélection des lignes dans la comparaison mémoïsée — par @RedwindA dans [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels) \: actualiser l’état du dialogue de test — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix \: restaurer la hauteur de l’iframe d’accueil — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web) \: ne pas tronquer le bas des détails de journal — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix \: gestion du contexte AWS AK/SK — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test \: nettoyer les tests backend contournant la récompense — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix \: préservation des blocs tool\_use lorsque arguments est vide, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix \: exécuter intégralement les tests groupés de modèles — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat \: mémorisation du nombre d’éléments par page entre navigations et sessions (#5377), par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table) \: éviter la troncature des cellules de composants — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth) \: supprimer les associations lors de la suppression définitive d’utilisateur — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat \: canal personnalisé avancé — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="Version stable · publiée le 13 juin 2026 à 16:15:40, heure de Chine">
  Points clés \: Claude Opus 4.8, meilleure compatibilité des images OpenAI et édition des tarifs/tableaux plus pratique. Corrections d’interface, quotas, relais et fournisseurs.

  ### Nouveautés

  * Ajout de Claude Opus 4.8 (#5177).
  * Ajout du choix de supprimer ou conserver l’affinité quand un canal est désactivé (#5306).
  * Ajout d’une option d’échange du solde d’abonnement.
  * Affichage de l’ID utilisateur dans le profil (#5317).
  * Ajout du relais d’images en streaming et des éditions Images OpenAI (#4608).

  ### Corrections

  * Les formulaires donnent le focus à la première erreur après soumission (#5163).
  * Le nom personnalisé cc-switch n’est plus réinitialisé à la perte de focus (#5170).
  * Les icônes personnalisées de modèles restent synchronisées dans les tarifs (#5224).
  * Les erreurs avancées de canal s’affichent sans ouvrir des réglages sans rapport (#5239).
  * La conversion de devise actualise l’unité et la valeur des quotas/soldes (#5296).
  * Correction des images distantes Dify dans les requêtes de fichiers (#5134).
  * Correction de la résolution du modèle lors de la consultation des tâches vidéo (#5133).
  * Amélioration du relais GLM compatible Anthropic pour éviter les incompatibilités (#5307).
  * Adaptation OpenAI o-series limitée pour ne pas toucher des modèles incompatibles (#5293).
  * Les menus multisélection suivent le thème actif (#5328).
  * Correction de la normalisation de température Kimi K2.6 (#5390).
  * Ajout du filtrage par état des utilisateurs supprimés (#5464).
  * Les réglages de déploiement ne sont chargés que sur leur page (#5466).

  ### Améliorations

  * Journaux administrateur et modifications groupées plus performants à grande échelle (#5116).
  * Éditeur de tarifs amélioré \: disposition, sauvegarde des brouillons, éditeur JSON réutilisable et pas de six décimales (#5275).
  * Recherche de canaux plus réactive par temporisation et meilleure gestion de l’IME (#5393).
  * Rendu des tableaux, colonnes figées, disposition et badges améliorés (#5405).
  * Dimensions et pieds de dialogues améliorés (#5346).
  * Texte principal des pages publiques simplifié (#5339).

  ***

  ### Modifications

  * fix(web) \: améliorer le focus des erreurs de validation — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog) \: perte de focus lors du changement de nom cc-switch, par @GnezIew dans [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model) \: corriger l’ordre de l’index idx\_created\_at\_id en (created\_at, id) — par @realRoc dans [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf \: trier les journaux administrateur par created\_at pour utiliser l’index composite — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps) \: passer axios de 1.15.2 à 1.16.0 dans /web/classic — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat \: prendre en charge claude-opus-4-8 — par @hjxwz123 dans [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing) \: synchroniser les icônes personnalisées de modèles — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web) \: centraliser les versions des dépendances frontend partagées — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web) \: développement et compilation classique avec Rsbuild — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels) \: afficher les erreurs de validation avancée — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs \: améliorer les modèles de tickets — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix \: changement de valeur et d’unité du solde, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify) \: initialiser le pointeur de fichier avant l’affectation d’image distante — par @Pluviobyte dans [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor) \: résoudre le modèle pour GET /v1/video/generations/\:task\_id — par @Pluviobyte dans [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix \: configurer le délai des connexions inactives du relais — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat \: effacement facultatif de l’affinité d’un canal désactivé, par @GuangYiDing dans [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay) \: corriger GLM compatible Anthropic en évitant l’encodage chunked — par @Chen011214 dans [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix \: limiter les corps de requêtes anonymes — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n) \: clarifier le texte de l’adaptateur de raisonnement — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix \: restriction de l’adaptation des modèles OpenAI o, par @USER-HFC dans [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix \: réutiliser le tampon d’analyse de flux dans les gestionnaires de canaux — par @xujiantop-crypto dans [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web) \: afficher l’ID utilisateur dans le profil — par @P2K0 dans [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing) \: améliorer l’ergonomie de l’éditeur de tarifs — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web) \: simplifier le texte principal des pages publiques — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web) \: améliorer tailles et disposition des dialogues — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix \: respecter le thème des menus multisélection — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix \: aligner le badge de coût du journal mobile — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix \: accepter un pas de six décimales dans l’éditeur de tarifs — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai) \: relayer les images en streaming et les éditions Images API — par @gaoren002 dans `#4608`
  * perf(web) \: temporiser la recherche de canaux et attendre la fin de composition IME — par @QAbot-zh dans [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix \: normaliser la température Kimi K2.6 — par @bensonfx dans [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web) \: améliorer rendu des tableaux et colonnes figées — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table) \: améliorer disposition et badges — par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit) \: ajouter des journaux d’audit de sécurité localisés — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore \: mettre à jour le canal Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix \: filtrer l’état des utilisateurs supprimés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix \: charger les réglages de déploiement uniquement sur leur page — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### Nouveaux contributeurs

  * @GnezIew a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="Version stable · publiée le 26 mai 2026 à 22:20:13, heure de Chine">
  ### Points clés

  v1.0.0-rc.10 améliore l’interface, la fiabilité du relais et les opérations d’administration. Cette version ajoute des thèmes et l’achat d’abonnements avec le solde, tout en améliorant les journaux, les canaux, les webhooks, les paiements et les appels d’outils des fournisseurs.

  ### Nouveautés

  * Nouveaux thèmes Anthropic et Simple Large, police à empattements configurable et très grande échelle.
  * Les abonnements peuvent désormais être achetés avec le solde.

  ### Corrections

  * Les canaux désactivés automatiquement ne sont plus sélectionnés et les actions ne dupliquent plus les notifications (#4983).
  * Relais d’outils Gemini/Claude plus fiable, y compris pour les appels simultanés (#5095).
  * Le relais d’images applique correctement la qualité demandée (#5103).
  * Les filtres d’utilisation correspondent exactement sauf joker explicite ; les erreurs amont énormes sont raccourcies pour garder des journaux lisibles (#5097).
  * Traitement des webhooks plus fiable (#5047).
  * Sauvegarde Waffo cohérente et options anciennes masquées (#5110).
  * Les paramètres système détectent les modifications non enregistrées et évitent les entrées numériques invalides.

  ### Améliorations

  * Les gros médias relayés consomment moins de mémoire pour une meilleure stabilité en charge.
  * Paramètres système et création/édition de canaux plus clairs et compacts.
  * Journaux et interface par défaut mieux adaptés au mobile \: espacement, badges, graphiques et lecture en mode sombre.
  * Section principale d’accueil renouvelée avec deux colonnes et nouveau texte.

  ***

  ### Modifications

  * 🐛 fix(channel) \: retirer du cache les canaux multiclés désactivés automatiquement — par @t0ng7u dans [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[Correction] traitement des webhooks — par @Hill-waffo dans [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment) \: masquer les anciens paramètres Waffo Pancake — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay) \: corriger la gestion du paramètre de qualité d’image — par @lanfunoe dans [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix \: tronquer les journaux amont surdimensionnés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix \: suppression du décalage fcIdx -1 et collisions d’appels parallèles, par @learner-i dans [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix \: corriger tool\_use de Gemini vers Claude — par @nekohy dans [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix \: gérer la recherche paginée des clés API — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix \: éviter les notifications d’actions de canal doublées — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix \: unifier la sauvegarde des paramètres Waffo — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix \: utiliser le véritable ID utilisateur pour tester un canal — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix \: conserver des filtres exacts sauf joker explicite — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### Nouveaux contributeurs

  * @learner-i a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="Version stable · publiée le 22 mai 2026 à 16:25:46, heure de Chine">
  #### Points clés

  Ajout de Waffo Pancake avec association catalogue/produit administrateur et améliorations API/administration. Cohérence des métadonnées et tarifs, diagnostic de canal, filtres de rapports et efficacité de traitement améliorés.

  #### Nouveautés

  * Ajout de Waffo Pancake avec association catalogue/produit administrateur (#4935).

  #### Corrections

  * Le tableau de bord respecte la visibilité configurée (#4975).
  * Les résumés de performance n’incluent que les groupes actifs (#4976).
  * Tarifs normalisés pour éviter des affichages incohérents (#4985).
  * Le propriétaire des modèles est résolu depuis les canaux actifs pour fiabiliser les listes (#4416).
  * Les liens du frontend par défaut pointent vers les bonnes routes (#5016).
  * Restauration des anciens filtres d’utilisation pour éviter une régression.

  #### Améliorations

  * Les tests de canal donnent des détails d’échec plus clairs (#4988).
  * Coût de traitement des requêtes réduit pour améliorer les performances en charge (#5009).

  ***

  ### Modifications

  * fix \: exposer l’audit des remplacements de paramètres pour les champs sensibles des messages — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix \: respecter la visibilité du tableau de bord — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix \: limiter les métriques aux groupes actifs — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix \: améliorer l’affichage des échecs de test — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix \: normaliser les écarts d’affichage des tarifs — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix \: résoudre owned\_by depuis les canaux actifs — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf \: optimiser l’extraction de métadonnées et le filtrage des champs désactivés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix \: corriger les routes codées en dur du frontend par défaut — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * Correction de Turnstile absent à l’inscription après changement d’interface, par @JunXiaoRuo dans [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[Fonction demandée] Waffo Pancake \: intégration complète, abonnements et association de catalogue administrateur — par @Hill-waffo dans [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix \: appliquer la conformité des abonnements Waffo et actualiser l’ID produit — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### Nouveaux contributeurs

  * @JunXiaoRuo a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="Version stable · publiée le 19 mai 2026 à 16:54:08, heure de Chine">
  #### Nouveautés

  * Ajout de la source de clé `request_header` (#4903).

  #### Corrections

  * Corrections groupées de l’interface Web par défaut (#4880, #4893, #4817, #4877, #4898, #4876).
  * Correction des remarques de canal impossibles à vider (#4886).
  * Correction des filtres de journaux d’utilisation (#4883).
  * Correction de validation des quotas illimités de clés API (#4881).
  * Contrôle d’accès appliqué à la navigation des modules publics (#4889).
  * Filtres de groupe correctement appliqués aux listes de canaux (#4847, #4885).
  * Correction des noms de colonnes ambigus lors des upserts `PerfMetric` (#4684).
  * Ajout des espaces réservés d’analyse manquants dans le thème par défaut (#4928).
  * Le bouton de mot de passe oublié soumet correctement grâce à son type (#4910).
  * Disposition normalisée des onglets de détail de modèle (#4938).
  * Correction de création et suppression d’utilisateurs dans la gestion (#4818).
  * Le lien d’inscription suit la configuration de disponibilité (#4871).
  * Libellés de pagination ModelCardGrid actualisés (#4675).
  * Confirmation de réinitialisation du mot de passe localisée (#4769).
  * Présélections de recharge visibles en mode sombre (#4897).
  * Correction de la mauvaise couleur du point API causée par un token sémantique incorrect (#4824).
  * Correction des échecs silencieux de sauvegarde d’informations API avec couleur invalide (#4823).
  * Utilisation du bon champ `aff_code` dans l’inscription (#4965).
  * Largeur adaptative des filtres à facettes dans les tableaux (#4966).
  * Correction des liaisons de formulaire obsolètes à la soumission des clés (#4967).

  #### Améliorations

  * Performances améliorées en évitant le formatage anticipé des journaux debug (#4929).

  ***

  ### Modifications

  * fix \: permettre de vider les remarques de canal — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix \: corriger les filtres des journaux d’utilisation — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web) \: valider les quotas illimités des clés API — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix \: appliquer le contrôle d’accès à la navigation publique — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix \: appliquer le filtre de groupe dans GetAllChannels — par @draftgo dans [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix \: qualifier les colonnes de PerfMetric upsert pour éviter l’ambiguïté PostgreSQL — par @SAY-5 dans [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix \: filtrer les listes de canaux par groupe — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat \: source de clé request\_header — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix \: langues et textes de la nouvelle interface, par @QuentinHsu dans [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix \: ajouter les espaces umami et ga4 dans index.html du thème par défaut — par @NitroRCr dans [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf \: éviter le formatage anticipé des journaux debug — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix \: ajouter type="submit" au bouton de mot de passe oublié — par @lihan3238 dans [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web) \: normaliser les onglets de détail de modèle — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user) \: corriger création et suppression dans la gestion — par @bugmaker2 dans [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth) \: exposer register\_enabled dans /api/status et conditionner le lien d’inscription — par @Gnonymous dans [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default) \: clarifier la pagination ModelCardGrid — par @ellisfan dans [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth) \: localiser la confirmation de nouveau mot de passe — par @neow021 dans [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet) \: rendre les présélections visibles en mode sombre — par @xinnyu dans [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default) \: corriger la couleur API liée aux tokens sémantiques — par @Micah-Zheng dans [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default) \: gérer la sauvegarde API avec couleur invalide ou résultat non vérifié — par @Micah-Zheng dans [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth) \: utiliser aff\_code dans l’inscription (#4945) — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table) \: adapter la largeur du filtre à facettes (#4905) — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys) \: appeler directement le gestionnaire de soumission pour éviter une liaison obsolète (#4858) — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### Nouveaux contributeurs

  * @draftgo a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="Version stable · publiée le 13 mai 2026 à 22:29:13, heure de Chine">
  ### Points clés

  Cette version enregistre les ID amont dans les journaux et ajoute une confirmation de conformité avant les fonctions payantes. Si la table `logs` est volumineuse, ajoutez préalablement la colonne `upstream_request_id` et son index avec du DDL en ligne pour éviter une migration longue.

  ### Nouveautés

  * Ajout du suivi des ID de requête amont dans les journaux pour faciliter le diagnostic sans écraser involontairement les en-têtes de réponse.
  * Ajout d’une confirmation de conformité avant les fonctions payantes.

  ### Corrections

  * Le sélecteur de canal ne masque plus des options valides quand il reçoit le focus (#4829).

  ### Autres

  * Avis de mise à niveau \: la table `logs` contient maintenant la colonne `upstream_request_id` et son index. Pour une grande installation, exécutez au préalable le DDL en ligne adapté ci-dessous pour éviter une migration automatique longue ou bloquante.

  MySQL / InnoDB \:

  ```sql
  -- 1. Add the column using online DDL.
  ALTER TABLE logs
    ADD COLUMN upstream_request_id VARCHAR(128) NOT NULL DEFAULT '',
    ALGORITHM=INPLACE, LOCK=NONE;

  -- 2. Add the index using online DDL.
  ALTER TABLE logs
    ADD INDEX idx_logs_upstream_request_id (upstream_request_id),
    ALGORITHM=INPLACE, LOCK=NONE;
  ```

  PostgreSQL 11+ \:

  ```sql
  -- 1. Add the column without rewriting the table on PG 11+.
  ALTER TABLE logs
    ADD COLUMN IF NOT EXISTS upstream_request_id VARCHAR(128) NOT NULL DEFAULT '';

  -- 2. Add the index concurrently to avoid blocking reads and writes.
  CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_logs_upstream_request_id
    ON logs (upstream_request_id);
  ```

  ***

  ### Modifications

  * chore(deps) \: passer axios de 1.15.0 à 1.15.2 dans /web/classic — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev) \: passer ip-address de 10.1.0 à 10.2.0 dans /electron — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * Correction de la liste de canaux incomplète, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="Version stable · publiée le 12 mai 2026 à 16:53:57, heure de Chine">
  ### Points clés

  Tableau de bord renouvelé avec métriques de modèles intégrées et santé plus claire. Ajout des liens DeepChat et correction de régressions d’interface, portefeuille, Playground et ratios.

  ### Nouveautés

  * Vue d’ensemble redessinée avec métriques de modèles et panneau de santé plus clair.
  * Prise en charge des liens profonds DeepChat pour ouvrir directement les conversations compatibles (#4668).

  ### Corrections

  * Les moyens de paiement utilisent la bonne configuration de recharge pour afficher leur disponibilité (#4599).
  * Les ratios de groupes respectent la configuration entre groupes (#4772).
  * Les menus du thème par défaut déclenchent correctement leurs gestionnaires de sélection (#4787).
  * Playground accepte les anciens messages classiques sans erreur (#4650).
  * Correction de régressions v1, notamment descriptions vides et problèmes de disposition (#4802).

  ### Améliorations

  * Interface et graphiques suivent les thèmes partagés pour uniformiser couleurs, contrôles et arrondis.
  * Les images Docker incluent les licences du projet et des tiers pour faciliter la conformité (#4739).

  ***

  ### Modifications

  * feat \: prendre en charge les liens profonds DeepChat — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix \: exclure THIRD-PARTY-LICENSES.md de .dockerignore pour Docker — par @yeying-xingchen dans [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet) \: lire la disponibilité de recharge dans topupInfo plutôt que status — par @ImogeneOctaviap794 dans [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default) \: utiliser getUserGroups pour respecter GroupGroupRatio — par @Micah-Zheng dans [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default) \: gérer onSelect de DropdownMenuItem — par @lihan3238 dans [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default) \: protéger Playground contre l’ancienne structure classique — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix \: corriger les problèmes de l’interface par défaut — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### Nouveaux contributeurs

  * @yeying-xingchen a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="Version stable · publiée le 6 mai 2026 à 22:25:59, heure de Chine">
  ### Points clés

  Édition d’images OpenAI plus fiable \: références et métadonnées conservées pour ne pas perdre le contexte (#4646). Ajout de badges de performance et correction de facturation et menus.

  ### Nouveautés

  * Ajout de badges de performance dans les listes pour comparer rapidement les modèles.

  ### Corrections

  * Les éditions OpenAI conservent références et métadonnées lors du relais (#4646).
  * Formulaires de facturation corrigés pour fiabiliser recharge et paramètres.
  * Menus et sélecteurs fonctionnent après la mise à jour des composants (#4655).

  ### Changements incompatibles

  * Les intégrations doivent lire le lien de recharge dans l’API d’informations de recharge, plus dans status.

  ### Illustrations

  | Classement de disponibilité des modèles                                                                                        | Interface de tarifs et paramètres renouvelée                                                                                   |
  | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
  | ![Illustration des notes de version Gallery](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Illustration des notes de version Gallery](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Modifications

  * fix \: conserver les champs de référence des éditions OpenAI — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix \: migrer le sélecteur vers l’API items de Base UI — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="Version stable · publiée le 6 mai 2026 à 18:43:33, heure de Chine">
  ### Points clés

  v1.0.0-rc.3 ajoute un classement des modèles avec disponibilité et performances pour comparer la fiabilité avant de choisir routes ou fournisseurs. Tarifs, paramètres et contrôles de tableaux du thème par défaut sont également renouvelés.

  ### Nouveautés

  * Ajout d’un classement avec disponibilité et performances réelles pour comparer la fiabilité (#4633).

  ### Améliorations

  * Interface par défaut renouvelée \: composants Base UI, thèmes et barres d’outils de tableaux (#4633).
  * Organisation de la tarification système simplifiée pour la lecture et la gestion.

  ### Corrections

  * Le tableau de canaux trie correctement côté serveur (#4600).
  * Correction des informations de paiement d’abonnement dans l’interface par défaut.

  ### Illustrations

  | Classement de disponibilité des modèles                                                                                        | Interface de tarifs et paramètres renouvelée                                                                                   |
  | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
  | ![Illustration des notes de version Gallery](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Illustration des notes de version Gallery](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Modifications

  * feat(web/default) \: refonte unifiée, Base UI, thèmes, classement et barres d’outils — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat \: recueillir les métriques de performance des modèles — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix \: activer le tri serveur du tableau de canaux — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="Version stable · publiée le 30 avril 2026 à 20:42:48, heure de Chine">
  ### Points clés

  v1.0.0-rc.2 permet de basculer entre les interfaces nouvelle et classique pour tester les parcours et revenir rapidement à l’ancienne interface. Cette version candidate modernise les pages principales de la console et corrige la liaison d’adresse e-mail, la tarification par paliers, les groupes de clés API et les URL de base Vertex personnalisées.

  ### Nouveautés

  * Ajout d’une bascule nouveau/classique pour adopter progressivement le frontend sans perdre les anciens parcours.

  ### Améliorations

  * Console renouvelée \: tarifs, contrôles du tableau de bord et des journaux, filtres, navigation et adaptation mobile.

  ### Corrections

  * Correction de l’association e-mail dans la nouvelle interface (#4551).
  * Saisie numérique des tarifs par paliers plus fiable (#4536).
  * Correction de valeurs et libellés mal affichés dans la tarification par paliers (#4530).
  * Les clés API apparaissent dans les groupes attendus du thème par défaut (#4548).
  * Les URL Vertex personnalisées routent correctement avec un préfixe de passerelle (#4200).

  ### Illustrations

  | Page de tarifs renouvelée                                                                                      | Contrôles du tableau de bord et des analyses                                                                                      |
  | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
  | ![Page de tarifs renouvelée](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![Contrôles du tableau de bord et des analyses](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### Modifications

  * fix \: groupe des clés API du thème par défaut, par @Micah-Zheng dans [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix \: association de l’adresse e-mail dans la nouvelle interface, par @SHLE1 dans [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix \: fiabiliser la saisie numérique des tarifs par paliers — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex) \: respecter base\_url comme préfixe de passerelle — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web) \: affichage de la facturation par paliers avec Base64 ou balises incorrects, par @wans10 dans [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### Nouveaux contributeurs

  * @SHLE1 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="Version stable · publiée le 29 avril 2026 à 20:15:01, heure de Chine">
  v1.0.0-rc.1 est la première version candidate de 1.0, centrée sur un frontend v1 entièrement reconstruit pour une administration plus claire, rapide et complète.

  Cette version renouvelle navigation, configuration, analyses et journaux pour simplifier la gestion quotidienne avant la sortie v1 finale.

  ![Illustration des notes de version v1.0.0-rc.1](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### Nouveautés

  * Frontend v1 reconstruit \: navigation et disposition modernes, éditeur visuel de remplacements de paramètres et accès simplifié aux réglages/thèmes (#4265).

  ### Améliorations

  * Tableaux de bord et graphiques améliorés \: analyses claires, meilleur tri et infobulles informatives.
  * Journaux améliorés \: types, noms, avatars et tableaux plus lisibles.
  * Dispositions, tableaux et formulaires partagés harmonisés pour une interface cohérente.

  ### Corrections

  * Les thèmes chargés depuis la base sont correctement appliqués à l’exécution (#4518).
  * Les champs de raisonnement vides sont conservés lors du relais au lieu d’être supprimés silencieusement (#4520).
  * Les marqueurs de champs obligatoires sont cohérents (#4533).

  ***

  ### Modifications

  * 🚀 feat \: lancement v1.0, frontend nouvelle génération entièrement reconstruit — par @t0ng7u dans [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix \: préservation des contenus de raisonnement vides Message.ReasoningContent/Reasoning lors du relais, par @heimoshuiyu dans [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix \: synchroniser le thème à l’exécution après chargement de la base — par @Micah-Zheng dans [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### Nouveaux contributeurs

  * @Micah-Zheng a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 — version de délimitation des licences

<Callout type="note" title="Préversion · publiée le 28 avril 2026 à 14:26:06, heure de Chine">
  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **Ressources à télécharger**

  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="Version stable · publiée le 27 avril 2026 à 22:11:42, heure de Chine">
  ### Nouveautés

  * Synchronisation des modèles plus précise \: découverte amont, tarifs automatiques depuis les fournisseurs, affichage des modèles retirés et maintien des tarifs pendant les délais (#4452).
  * Les utilisateurs comprennent les dates de création et dernière connexion pour l’audit (#4450).
  * Correspondance configurable des modèles pour Messages natif Ali afin de router vers les amonts compatibles (#4468).

  ### Corrections

  * Les outils acceptent des arguments JSON bruts pour les fournisseurs renvoyant des objets (#4469).
  * Les mises à jour de configuration gèrent plus sûrement les champs objets JSON.

  ### Améliorations

  * Les messages expliquent clairement qu’un canal est ignoré quand l’affinité est désactivée (#4453).

  ***

  ### Modifications

  * fix(channel) \: charger les correspondances lors des vérifications amont — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat \: synchroniser les tarifs depuis le point d’accès fournisseur — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix \: clarifier les reprises quand l’affinité est désactivée — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat \: configurer les correspondances de modèles Messages natif Ali — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix \: accepter les arguments d’outils JSON bruts en réponse — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat \: afficher les modèles amont retirés dans le dialogue de récupération — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * Ajout des dates de création et dernière connexion, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="Version stable · publiée le 25 avril 2026 à 13:27:23, heure de Chine">
  ### Points clés

  Ce correctif ajoute `len` dans les conditions de paliers et l’aide aux invites LLM, pour définir des règles selon la longueur.

  ### Nouveautés

  * Ajout de la variable `len` dans les conditions de paliers et l’aide aux invites pour définir des règles de longueur.

  ***

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="Version stable · publiée le 24 avril 2026 à 22:20:58, heure de Chine">
  #### Nouveautés

  * Ajout des suffixes de raisonnement DeepSeek V4 (#4428)

  #### Corrections

  * Les modèles à tarification par paliers ne sont plus exclus de la liste (#4431)

  ***

  ### Modifications

  * fix \: inclure les modèles à paliers dans la liste — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat \: gérer et tester les suffixes de raisonnement DeepSeek V4 — par @HynoR dans [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="Version stable · publiée le 24 avril 2026 à 14:09:21, heure de Chine">
  ### Points clés

  Cette version introduit la tarification par paliers fondée sur les expressions `expr`, permettant des règles dynamiques complexes. Exemple simple \: `tokens <= 128000 ? 0.002 : 0.004`, qui applique automatiquement un tarif bas sous 128K tokens et un tarif plus élevé au-delà.

  ### Nouveautés

  * Ajout de l’évaluation des expressions `expr` dans la facturation pour des paliers dynamiques avec préréglages (#4409).
  * Ajout d’une interface de tarifs d’outils et amélioration de leurs quotas.
  * Affichage de l’ID utilisateur dans les factures de recharge administrateur (#4349).
  * Ajout d’une colonne de dernière utilisation des jetons (#4372).
  * Longueur de colonne des clés assouplie pour migrer les anciens jetons plus longs (#4401).

  ### Corrections

  * Le ratio N n’est appliqué qu’aux modèles d’image (#4412).
  * Les suppléments d’outils textuels sont conservés au règlement par paliers (#4162).
  * Correction du ratio de complétion du modèle `gpt-5.5` (#4414).
  * Correction du type d’affichage des tarifs de modèles (#4426).
  * Correction de plantages et cas limites dans l’éditeur de paliers et le règlement.
  * Tests de canaux adaptés aux modèles à tarification par paliers.

  ### Améliorations

  * Ajout de paliers préréglés Doubao Seed 1.8 pour les remises.
  * Remplacement des composants Card par des div pour harmoniser la disposition.
  * Calculs internes fondés sur le quota par unité pour plus de précision.

  ***

  ### Modifications

  * fix(channel-test) \: tester les modèles à paliers — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * Affichage de l’ID utilisateur dans les factures de recharge administrateur, par @uskyu dans [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * Ajout de la dernière utilisation des jetons, par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps) \: passer github.com/jackc/pgx/v5 de 5.9.0 à 5.9.2 — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev) \: passer @xmldom/xmldom de 0.8.12 à 0.8.13 dans /electron — par @dependabot\[bot] dans [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * Assouplir la longueur des clés pour les migrations anciennes — par @XiaoAI1024 dans [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing) \: conserver les suppléments d’outils textuels au règlement — par @yyhhyyyyyy dans [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat \: expressions de tarification par paliers dans la facturation — par @Calcium-Ion dans [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image) \: appliquer le ratio N seulement aux modèles d’image — par @xyfacai dans [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix \: corriger le ratio de complétion gpt-5.5 — par @jingx8885 dans [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix \: utiliser le bon type d’affichage des tarifs — par @feitianbubu dans [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### Nouveaux contributeurs

  * @uskyu a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="Version stable · publiée le 22 avril 2026 à 23:04:03, heure de Chine">
  #### Nouveautés

  * Ajout de Waffo Pay pour les recharges et paiements (#4089).

  #### Corrections

  * Correction d’une carte de recharge dont l’interface pouvait casser (#4388).

  #### Améliorations

  * Ajout du paramètre Gemini `IncludeServerSideToolInvocations` dans `ToolConfig` pour améliorer les outils Gemini récents (#4311).
  * Fiabilité et ergonomie Codex améliorées \: renouvellement des identifiants de canaux désactivés, tests automatiques en streaming et détail d’utilisation (#4324).

  ***

  ### Modifications

  * fix(gemini) \: ajouter IncludeServerSideToolInvocations dans ToolConfig — par @KoellM dans [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * refactor \: paiement — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup) \: importer le Tag manquant de la carte de recharge — par @gaoren002 dans `#4388`
  * chore \: améliorer le dialogue d’utilisation Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix \: utiliser le streaming pour le test automatique Codex — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix \: renouveler les identifiants Codex des canaux désactivés — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix \: exiger la bonne vérification pour modifier les passkeys — par @seefs001 dans [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### Nouveaux contributeurs

  * @KoellM a apporté sa première contribution dans [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 a apporté sa première contribution dans `#4388`

  **Historique complet**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **Ressources à télécharger**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [Code source (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [Code source (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***