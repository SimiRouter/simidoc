# Configuration de FluentRead

<Callout type="info" title="">
  🌊
  FluentRead est une extension de traduction open source qui vise une lecture aussi naturelle que dans votre langue maternelle.
</Callout>

* Projet \: [https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## Fonctions principales

### Moteurs de traduction intelligents

* **Plusieurs moteurs** \: plusieurs moteurs de traduction
* **Traduction classique** \: Microsoft Translator, Google Traduction, DeepL et d’autres.
* **Grands modèles d’IA** \: OpenAI, DeepSeek, Kimi, Ollama et d’autres.
* **Moteurs personnalisés** \: configuration de services de traduction sur mesure.

### Lecture immersive

* **Affichage bilingue** \: original et traduction côte à côte pour faciliter la lecture.
* **Traduction de la sélection** \: sélectionnez du texte pour le traduire immédiatement.
* **Copie en un clic** \: copiez rapidement la traduction.
* **Traduction intégrale** \: traduisez toute la page avec le bouton flottant, sans rechargement.

### Confidentialité et personnalisation

* **Données et confidentialité** \: la traduction en ligne et les modèles cloud transmettent le texte à traduire au service configuré. Consultez ses règles de traitement des données et n’envoyez pas d’informations sensibles à un fournisseur non fiable.
* **Personnalisation** \: de nombreuses options pour différents besoins.
* **Entièrement gratuit** \: projet open source et non commercial.

## Installation

| Navigateur  | Installation                                                                                                                                                                                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**  | [Chrome Web Store](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [Miroir accessible en Chine](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Microsoft Edge Add-ons](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                                         |
| **Firefox** | [Modules complémentaires Firefox](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                            |

## Configuration

### Configuration manuelle dans FluentRead

Dans [Gestion des clés API](https://api.dwchainless.com/keys) copiez la clé, puis ouvrez les paramètres FluentRead et renseignez \:

| Paramètre             | Valeur                                                                  |
| --------------------- | ----------------------------------------------------------------------- |
| Service de traduction | New API                                                                 |
| Jeton d’accès         | La clé API SimiRouter copiée précédemment                               |
| Interface NewAPI      | `https://api.dwchainless.com` (sans `/v1`)                              |
| Modèle                | Sélectionnez ou saisissez l’ID complet d’un modèle accessible au compte |

Enregistrez, traduisez un court texte non sensible, puis vérifiez l’appel dans SimiRouter. Une traduction en ligne transmet le texte au service configuré.