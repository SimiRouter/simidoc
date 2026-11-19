# Images

Choisissez d’abord le **protocole API**, puis l’**effet** recherché, et vérifiez enfin les **dimensions, la qualité, le format et le nombre d’images**. Le protocole définit la structure des requêtes et réponses ; l’effet dépend du modèle et de la consigne ; les spécifications définissent la sortie attendue. Ces trois aspects sont distincts.

La génération et l’édition renvoient des images ; la compréhension reçoit une image et produit du texte ou des données structurées. Ajouter des paramètres d’image ne donne pas de capacité de génération à un modèle textuel. Avant tout appel, vérifiez dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/) l’identifiant exact du modèle, les API prises en charge, le groupe tarifaire et le crédit. Les requêtes réelles peuvent être facturées.

## Aperçu

| Ce que vous voulez faire                    | Entrée                                        | Sortie                        | Endpoint typique              |
| ------------------------------------------- | --------------------------------------------- | ----------------------------- | ----------------------------- |
| Générer une image à partir de texte         | Prompt                                        | Nouvelle image                | `POST /v1/images/generations` |
| Modifier une image existante                | Prompt + une ou plusieurs images de référence | Image éditée                  | `POST /v1/images/edits`       |
| Générer des images pendant une conversation | Messages de conversation + outil image        | Résultat mixte image et texte | `POST /v1/responses`          |
| Faire décrire une image par le modèle       | Image + question                              | Texte, pas une nouvelle image | `POST /v1/chat/completions`   |

## Concepts clés

Commencez par distinguer trois types de nombres ; les paramètres et les prix qui suivent deviennent alors compréhensibles \:

* **Dimensions en pixels** \: largeur × hauteur réelles, par exemple `1024x1024`. Elles déterminent la résolution réelle du fichier, pas sa taille, et ne correspondent pas à un palier de qualité.
* **Rapport d’aspect** \: proportions comme `1:1`, `16:9`, `9:16`, qui déterminent seulement la forme du cadre. Un même rapport peut correspondre à plusieurs dimensions en pixels ; indiquer uniquement le rapport ne revient pas à spécifier la taille de sortie.
* **Palier de résolution** \: paliers comme `1K`, `2K`, `4K`. Les paliers natifs des fournisseurs sont définis par le côté le plus long ou la gamme de produits, tandis que les paliers de facturation à l’image de ce site sont classés selon le côté le plus long ; leurs noms sont identiques mais leurs limites peuvent différer, et ils ne se déduisent pas directement l’un de l’autre.

Trois malentendus fréquents subsistent \: `quality` contrôle la qualité de rendu, pas la qualité de compression ; PNG, JPEG et WebP sont des formats de fichier, et changer l’extension ne convertit pas le format ; Base64 et URL ne sont que des modes de livraison, pas des résolutions. Voir la section 4 ci-dessous, « Spécifications et facturation des images », pour la comparaison détaillée.

## 1. Les API \: choisir un protocole

Les trois protocoles possèdent leurs propres paramètres de requête, champs de réponse et exemples. Chacun explique aussi les scripts, l’utilisation avec un agent, l’enregistrement des résultats et le traitement des erreurs ; nul besoin de commencer par un guide générique limité à OpenAI.

| Protocole               | API / capacité                                                    | Point de terminaison                                           | Résultat principal                                                         | Documentation                                             |
| ----------------------- | ----------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------- |
| OpenAI                  | Texte vers image                                                  | `POST /v1/images/generations`                                  | `data[].b64_json` ; les modèles compatibles peuvent aussi renvoyer une URL | [Génération](/simidoc/fr/apps/api/images/openai/generations)                        |
| OpenAI                  | Édition / image vers image                                        | `POST /v1/images/edits`                                        | Image modifiée                                                             | [Édition](/simidoc/fr/apps/api/images/openai/edits)                                 |
| OpenAI                  | Génération conversationnelle                                      | `POST /v1/responses`, avec l’outil `image_generation`          | Résultats de l’outil image dans `output[]`                                 | [Génération conversationnelle](/simidoc/fr/apps/api/images/openai/chat-format)      |
| OpenAI                  | Compréhension d’image                                             | `POST /v1/chat/completions`, avec une entrée `image_url`       | Analyse textuelle, et non image générée                                    | [Compréhension d’image](/simidoc/fr/apps/api/images/openai/vision)                  |
| Gemini                  | Texte vers image                                                  | `POST /v1beta/models/{model}:generateContent`                  | `candidates[].content.parts[].inlineData`                                  | [Génération](/simidoc/fr/apps/api/images/gemini/generate)                           |
| Gemini                  | Édition / retouches successives                                   | Même point de terminaison, avec texte et images                | Image dans les éléments de contenu renvoyés                                | [Édition](/simidoc/fr/apps/api/images/gemini/edits)                                 |
| Gemini                  | Compréhension d’image                                             | Même point de terminaison, avec un modèle acceptant les images | Analyse textuelle                                                          | [Compréhension des médias](/simidoc/fr/apps/api/chat/gemini-media)          |
| Qwen                    | Texte vers image / édition                                        | `POST /v1/images/generations`, `POST /v1/images/edits`         | `data[].url` ou `data[].b64_json`                                          | [Génération](/simidoc/fr/apps/api/images/qwen/generations), [édition](/simidoc/fr/apps/api/images/qwen/edits) |
| Jimeng / Volcengine Ark | Texte vers image / génération à partir de références              | `POST /api/v3/images/generations`                              | `data[].url` ou `data[].b64_json`                                          | [Génération](/simidoc/fr/apps/api/images/jimeng)                                    |
| xAI Grok                | Texte vers image / génération multiple                            | `POST /v1/images/generations`                                  | `data[].url` ou `data[].b64_json`                                          | [Génération](/simidoc/fr/apps/api/images/grok)                                      |
| BFL FLUX                | Texte vers image / génération à partir de références (asynchrone) | `POST /v1/flux-pro-1.1` etc.                                   | `polling_url` d’abord, puis `result.sample` à la fin                       | [Génération](/simidoc/fr/apps/api/images/flux)                                      |

**La section Qwen utilise le corps de requête natif Qwen et appelle les points de terminaison `/v1/images/generations` et `/v1/images/edits` de la passerelle de ce site ; la réponse est toujours au format `data[]`.** Ne réécrivez pas le corps avec le champ `prompt` d’OpenAI ; l’identifiant de modèle doit correspondre au nom réellement fourni par le canal de ce site. Jimeng utilise le corps de requête natif Volcengine Ark ; le chemin de Grok est identique à OpenAI Images, mais les paramètres de cadre deviennent `aspect_ratio` et `resolution` ; FLUX n’a pas de génération synchrone et doit d’abord soumettre une tâche puis interroger `polling_url`. Ces trois protocoles ne peuvent pas recopier les champs les uns des autres.

Les modes d’appel diffèrent également \: OpenAI Images attend normalement le résultat complet, et seuls les modèles compatibles acceptent le flux d’événements d’image ; Gemini utilise `streamGenerateContent?alt=sse` pour le streaming ; les exemples Qwen et Jimeng de ce catalogue sont synchrones ; Grok est synchrone par défaut et peut aussi passer en tâche différée avec `deferred` ; FLUX est toujours en interrogation asynchrone. Ajouter un paramètre « asynchrone » ne les transforme pas en file de tâches universelle. Consultez les sections [OpenAI](/simidoc/fr/apps/api/images/openai), [Gemini](/simidoc/fr/apps/api/images/gemini), [Qwen](/simidoc/fr/apps/api/images/qwen), [Jimeng](/simidoc/fr/apps/api/images/jimeng), [Grok](/simidoc/fr/apps/api/images/grok) et [FLUX](/simidoc/fr/apps/api/images/flux) pour les requêtes, les sorties et les critères de fin.

## 2. Les effets \: choisir selon l’objectif

« Aquarelle », « remplacer l’arrière-plan » ou « composition de produit » sont généralement des tâches de génération ou d’édition, pas des API distinctes. Le tableau classe les tâches sans promettre leur prise en charge par tous les modèles ; vérifiez les limites du protocole et du modèle.

| Effet recherché                                                    | Entrées et points à préciser                                                             | API et limites                                                                                                              |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Création \: illustration, couverture, affiche, scène réaliste      | Sujet, composition, style, éclairage et texte à afficher                                 | Texte vers image ; vérifiez le texte et les détails                                                                         |
| Variante d’une référence \: reprendre le sujet ou la composition   | Image de référence et liste des éléments à conserver ou modifier                         | Édition / image vers image ; aucune fidélité pixel par pixel garantie                                                       |
| Changement de style \: photo en aquarelle, dessin au trait, etc.   | Référence et style cible ; préciser si le sujet et la disposition doivent être conservés | Modèle d’édition acceptant les références                                                                                   |
| Remplacement du fond, ajout ou retrait d’éléments, retouche locale | Zone à modifier ; masque si pris en charge                                               | API d’édition ; prise en charge et règles des masques propres au modèle                                                     |
| Composition multi-image \: produits, personnes et décor            | Rôle de chaque référence, relations entre sujets et disposition finale                   | Modèle d’édition multi-image ; vérifiez la limite d’images en entrée                                                        |
| Itérations \: modifier le résultat précédent                       | Historique ou références exigés par le protocole                                         | API prenant en charge les images sur plusieurs tours ; conserver un texte seul ne préserve pas forcément le contexte visuel |
| Ressources à fond transparent                                      | Demander un vrai canal alpha, et non un fond blanc ou un damier dessiné                  | Modèle et format de sortie compatibles avec la transparence                                                                 |
| Compréhension, extraction de texte, questions sur un graphique     | Image et objectif d’analyse                                                              | API de compréhension ; sortie textuelle, pas image retouchée                                                                |

Consultez les capacités et limites dans [Génération d’images OpenAI](https\://developers.openai.com/api/docs/guides/image-generation), [Génération et édition Gemini](https\://ai.google.dev/gemini-api/docs/image-generation) et [Édition Qwen](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api). Un exemple officiel ne garantit pas que le canal de la passerelle propose les mêmes fonctions.

## 3. Appeler l’API \: quatre étapes pour une première image

Quel que soit le protocole, l’appel suit le même ordre \: vérifier la configuration, choisir un endpoint, envoyer une requête minimale, puis lire et vérifier le résultat. Les étapes ci-dessous décrivent le flux général ; la page du protocole définit les champs exacts.

### 1. Vérifier l’URL, la clé et le modèle

* **URL de requête** \: la passerelle du site est `https://api.dwchainless.com` ; le chemin de l’endpoint dépend du protocole et de l’opération.
* **Clé** \: créez-la dans [Gestion des clés API](https://api.dwchainless.com/keys) et envoyez-la via `Authorization: Bearer $API_KEY` ; ne la placez jamais dans une consigne, le code source, une capture d’écran ou Git.
* **Modèle** \: copiez l’identifiant complet depuis [Modèles et prix](https://api.dwchainless.com/fr/pricing/) et vérifiez qu’il prend en charge l’endpoint visé. La génération, l’édition et la compréhension peuvent utiliser des modèles différents.

### 2. Choisir un endpoint et un format de requête

Choisissez un endpoint dans le tableau des protocoles ci-dessus, puis vérifiez le format du corps de requête \:

| Opération                    | Endpoint (format OpenAI)      | Format de requête                |
| ---------------------------- | ----------------------------- | -------------------------------- |
| Génération texte-image       | `POST /v1/images/generations` | JSON                             |
| Édition / image-to-image     | `POST /v1/images/edits`       | JSON `images[]` ou multipart     |
| Génération conversationnelle | `POST /v1/responses`          | JSON avec l’outil d’image activé |
| Compréhension d’image        | `POST /v1/chat/completions`   | JSON avec un élément `image_url` |

Gemini, Qwen, Jimeng, Grok et FLUX utilisent leurs propres champs de requête natifs ; ne copiez pas directement les champs OpenAI dans ces protocoles.

### 3. Envoyer une requête minimale

Pour le premier appel, générez une seule image sans streaming afin de vérifier l’authentification, le modèle et les paramètres. Exemple avec la génération OpenAI \:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

Une fois la réponse normale, augmentez `n`, ajustez les dimensions ou activez le streaming si nécessaire. Exemples multilingues complets \: [génération](/simidoc/fr/apps/api/images/openai/generations) et [édition](/simidoc/fr/apps/api/images/openai/edits).

**Forme de la réponse (indicative)** \: le Base64 d’une vraie réponse est très long ; seul son début est conservé ici. En cas de succès, examinez `data[]`, pas seulement le HTTP 200.

```json
{
  "created": 1763366400,
  "data": [{ "b64_json": "iVBORw0KGgoAAAANSUhEUg..." }],
  "usage": { "input_tokens": 28, "output_tokens": 4160, "total_tokens": 4188 }
}
```

### 4. Lire et vérifier le résultat

1. **Vérifier le statut** \: seul un code 2xx indique le succès ; pour un 4xx, contrôlez paramètres et droits ; pour un 5xx ou un délai dépassé, vérifiez d’abord si la requête a été exécutée.
2. **Lire le résultat** \: prenez les images dans `data[]` ; GPT Image renvoie `data[].b64_json`, les modèles compatibles peuvent renvoyer `data[].url` ; ne supposez pas la présence d’un premier élément.
3. **Enregistrer l’image** \: décodez le Base64 en binaire et choisissez l’extension selon le type MIME réel ; téléchargez les URL rapidement et sans la clé API.
4. **Vérifier** \: contrôlez que le fichier s’ouvre, ses dimensions réelles, sa transparence et son contenu, puis le journal d’utilisation. Un HTTP 200, un `data[]` vide ou un aperçu en streaming ne signifie pas que l’image finale est enregistrée.

## 4. Spécifications et facturation des images

### Ce que contrôle chaque réglage

| Spécification           | Sens et exemples                                                          | À ne pas confondre                                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Dimensions en pixels    | Largeur × hauteur réelles, par exemple `1024x1024`, `1536x1024`           | Ni taille du fichier, ni palier de qualité automatique                                                                                     |
| Rapport largeur/hauteur | Carré `1:1`, paysage `16:9`, portrait `9:16`                              | Un même rapport accepte plusieurs résolutions ; il ne fixe pas toutes les dimensions en pixels                                             |
| Palier de résolution    | Certains modèles ont des paramètres natifs `1K`, `2K`, `4K`               | Les dimensions dépendent aussi du modèle et du rapport ; ces paliers ne correspondent pas automatiquement aux seuils tarifaires de ce site |
| Qualité de génération   | Par exemple `quality` d’OpenAI, qui choisit une qualité de rendu          | Ce n’est ni `size`, ni la qualité de compression JPEG/WebP ; tous les modèles n’ont pas le même paramètre                                  |
| Format de fichier       | PNG, JPEG, WebP, etc., selon le MIME réellement renvoyé                   | Base64 et URL sont des modes de livraison, pas des formats d’image ; changer l’extension ne convertit pas le fichier                       |
| Fond transparent        | Canal alpha permettant la superposition                                   | Le modèle, les paramètres et le format doivent tous le permettre ; une simple consigne ne garantit pas un canal alpha                      |
| Nombre d’images         | Images ou candidats ; champs et limites propres au protocole et au modèle | Demander « trois images » dans la consigne ne règle pas le nombre API ; plusieurs entrées ne signifient pas plusieurs sorties              |

À rapport constant, doubler les côtés quadruple le nombre de pixels, sans garantir une amélioration proportionnelle des détails ou de la netteté. Choisissez selon l’usage, puis vérifiez les limites, le délai et le prix du modèle ; le palier maximal n’est pas toujours nécessaire.

Les champs, valeurs et exemples se trouvent dans les formats de requête [OpenAI](/simidoc/fr/apps/api/images/openai/generations), [Gemini](/simidoc/fr/apps/api/images/gemini/generate), [Qwen](/simidoc/fr/apps/api/images/qwen/generations), [Jimeng](/simidoc/fr/apps/api/images/jimeng), [Grok](/simidoc/fr/apps/api/images/grok) et [FLUX](/simidoc/fr/apps/api/images/flux). Pour OpenAI, consultez les [réglages officiels de sortie](https\://developers.openai.com/api/docs/guides/image-generation#customize-image-output) concernant qualité, format et transparence ; pour Qwen, les [spécifications officielles](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api). Ne copiez pas directement les paramètres d’un protocole vers un autre.

### Différences entre les paliers 1K, 2K et 4K facturés par image

Le tableau s’applique uniquement aux modèles explicitement facturés par image selon ces trois paliers sur la [page des prix des modèles](https://api.dwchainless.com/fr/pricing/). Les modèles facturés en tokens ou à d’autres prix fixes suivent leurs propres règles ; le nom « modèle d’image » ne suffit pas à déterminer la facturation.

| Palier de facturation | Côté le plus long                         | Exemples de dimensions (pixels) |
| --------------------- | ----------------------------------------- | ------------------------------- |
| 1K                    | Les deux côtés ≤ 1024 pixels              | 1024×1024                       |
| 2K                    | Côté le plus long > 1024 et ≤ 2048 pixels | 1280×720, 1536×1024             |
| 4K                    | Un côté > 2048 pixels                     | 2560×1440, 3840×2160            |

**Prix total = prix unitaire du palier sélectionné × nombre d’images facturées.** Lorsque l’API facture les résultats terminés, seules les images effectivement terminées comptent ; les aperçus intermédiaires du flux ne comptent pas. Les prix actuels et les journaux d’utilisation font foi pour le prix unitaire, le groupe et le débit final ; cette page ne fixe aucun montant.

Avec cette tarification à trois paliers, omettre `size` ou utiliser `auto` applique 1K par défaut seulement si aucun autre palier de dimensions valide n’est indiqué ; un champ natif de résolution explicite détermine toujours le palier. Les dimensions sont classées selon le côté le plus long demandé, pas le nombre total de pixels. Ainsi, `1280x720` relève de 2K et `2560x1440` de 4K.

**Le palier tarifaire ne garantit pas les dimensions de sortie.** Dans Gemini, `generationConfig.imageConfig.imageSize` sélectionne une résolution native du modèle ; vérifiez les pixels réels selon le modèle et le rapport. Ce site calcule le palier avec les champs de requête pris en charge, sans promettre une largeur et une hauteur uniformes. N’envoyez pas de champs de dimensions contradictoires et n’appliquez pas ces règles aux appels officiels directs ni aux modèles facturés en tokens.

### Ratios courants \: 14 ratios × 1K / 2K / 4K

Le tableau liste des dimensions prédéfinies courantes en 1K, 2K et 4K par rapport de forme, pour choisir rapidement un cadre. C’est une référence rapide de tailles, pas une liste de prise en charge par les modèles \: les ratios disponibles, les noms de préréglages et les limites par côté varient selon le modèle et la passerelle ; vérifiez la documentation du modèle ou l’erreur de l’API avant la requête.

Le palier K indiqué ici est un nom de préréglage, pas le palier tarifaire par image de cette page. Pour certains préréglages « 1K », le côté le plus long dépasse déjà 1024 pixels, ce que ce site classe en 2K ; par exemple, le préréglage 1K 16\:9 `1536x864` relève de 2K. La facturation suit toujours les dimensions demandées et les [Modèles et tarifs](https://api.dwchainless.com/fr/pricing/).

| Ratio     | Usage courant                      | Taille 1K   | Taille 2K   | Taille 4K       |
| :-------- | :--------------------------------- | :---------- | :---------- | :-------------- |
| `1:1`     | Avatar carré / produit             | `1024x1024` | `2048x2048` | `3840x3840`     |
| `4:3`     | Illustration paysage / visuel      | `1152x896`  | `2048x1536` | `3840x2880`     |
| `3:4`     | Affiche portrait / portrait        | `896x1152`  | `1536x2048` | `2880x3840`     |
| `16:9`    | Couverture paysage / diapositives  | `1536x864`  | `2048x1152` | `3840x2160`     |
| `9:16`    | Couverture verticale / fond mobile | `864x1536`  | `1152x2048` | `2160x3840`     |
| `3:2`     | Photographie paysage               | `1536x1024` | `2048x1360` | `3840x2560`     |
| `2:3`     | Photographie portrait              | `1024x1536` | `1360x2048` | `2560x3840`     |
| `5:4`     | Présentation produit paysage       | `1280x1024` | `2560x2048` | `3840x3072`     |
| `4:5`     | Produit vertical / image sociale   | `1024x1280` | `2048x2560` | `3072x3840`     |
| `21:9`    | Scène large / bannière             | `1792x768`  | `2048x880`  | `3840x1648`     |
| `1:4`     | Bande verticale étroite            | `512x2048`  | `768x3072`  | **Hors limite** |
| `4:1`     | Bande horizontale étroite          | `2048x512`  | `3072x768`  | **Hors limite** |
| `1.414:1` | Papier paysage série A approx.     | `1440x1024` | `2048x1456` | `3840x2720`     |
| `1:1.414` | Papier portrait série A approx.    | `1024x1440` | `1456x2048` | `2720x3840`     |

### Trois façons correctes d’écrire size

Certaines passerelles compatibles OpenAI acceptent les formes suivantes ; leur prise en compte dépend du modèle et de la passerelle. Si elles ne sont pas prises en charge, revenez aux pixels explicites.

| Forme                          | Extrait de requête                 | Usage                                                                     |
| :----------------------------- | :--------------------------------- | :------------------------------------------------------------------------ |
| Pixels explicites (recommandé) | `{"size":"1536x2048"}`             | Le plus direct ; évite les écarts de conversion des préréglages           |
| Ratio + résolution             | `{"size":"3:4","resolution":"2k"}` | Convertit avec le préréglage 2K, 3\:4                                     |
| Taille automatique             | `{"size":"auto"}`                  | Le modèle choisit les dimensions ; largeur et hauteur fixes non garanties |

* Indiquez le palier K dans `resolution` et les pixels ou un ratio dans `size` ; n’écrivez pas `2k` dans `size`.
* Utilisez un `x` minuscule comme séparateur de dimensions ; n’utilisez pas de signe de multiplication, de X majuscule, de tableau ni de chaîne avec ×.
* Un ratio dans `size` prime sur `aspect_ratio` seul ; des pixels explicites ou `auto` priment sur les préréglages de ratio.
* La limite officielle des tailles libres pour gpt-image-2 est 3840×2160 ; les combinaisons 4K `1:4` et `4:1` la dépassent et sont signalées comme hors limite par côté. Les autres modèles suivent leurs propres limites.
* Gemini et Qwen utilisent leurs propres champs de taille ; ces formes ne s’y appliquent pas directement.

### Dimensions courantes \: 28 formats

Les étiquettes indiquent seulement les paliers tarifaires ci-dessus, sans garantir la prise en charge des dimensions par le modèle. Vérifiez son API avant de choisir ; une étiquette tarifaire n’est pas une valeur de paramètre API.

| Usage / rapport                | Dimensions (pixels) et palier                                                    |
| ------------------------------ | -------------------------------------------------------------------------------- |
| Carré · 1\:1                   | 1024×1024 · 1K ; 1536×1536 · 2K ; 2048×2048 · 2K                                 |
| Couverture paysage · 16\:9     | 1280×720 · 2K ; 1536×864 · 2K ; 2048×1152 · 2K ; 2560×1440 · 4K ; 3840×2160 · 4K |
| Vidéo portrait / Story · 9\:16 | 720×1280 · 2K ; 864×1536 · 2K ; 1152×2048 · 2K ; 1440×2560 · 4K ; 2160×3840 · 4K |
| Illustration d’article · 3\:2  | 1536×1024 · 2K ; 1920×1280 · 2K ; 2400×1600 · 4K                                 |
| Affiche portrait · 2\:3        | 1024×1536 · 2K ; 1280×1920 · 2K ; 1600×2400 · 4K                                 |
| Bannière large · 2\:1          | 1536×768 · 2K ; 2048×1024 · 2K ; 2560×1280 · 4K ; 3840×1920 · 4K                 |
| Bannière ultra-large · 3\:1    | 1536×512 · 2K ; 1920×640 · 2K ; 2400×800 · 4K ; 3072×1024 · 4K ; 3840×1280 · 4K  |

## 5. Approfondir par protocole

Paramètres complets, structures de réponse, exemples de code et gestion des erreurs pour chaque protocole \:

* [Format OpenAI](/simidoc/fr/apps/api/images/openai)
* [Format Gemini](/simidoc/fr/apps/api/images/gemini)
* [Format Qwen](/simidoc/fr/apps/api/images/qwen)
* [Format Jimeng / Volcengine Ark](/simidoc/fr/apps/api/images/jimeng)
* [Format xAI Grok](/simidoc/fr/apps/api/images/grok)
* [Format BFL FLUX](/simidoc/fr/apps/api/images/flux)