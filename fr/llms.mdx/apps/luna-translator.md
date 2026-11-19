# Configuration de LunaTranslator

<Callout type="info" title="">
  LunaTranslator est un traducteur libre et gratuit pour visual novels et GalGame, destiné à faciliter la lecture dans votre langue.
</Callout>

* Projet \: [https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* Documentation du projet \: [https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## Fonctionnalités

* **HOOK** utilise principalement HOOK pour extraire le texte des visual novels compatibles ; consultez la documentation pour la compatibilité exacte

* **Traduction intégrée** certains jeux permettent d’intégrer directement la traduction pour une expérience immersive

* **HOOK dans les émulateurs** lit le texte par HOOK pour les jeux et émulateurs pris en charge

* **OCR** intègre un modèle OCR et plusieurs moteurs OCR en ligne ou hors ligne pour extraire le texte

* **Interfaces de traduction** permet de configurer plusieurs modèles de langage et services de traduction hors ligne

* **Apprentissage des langues** propose la segmentation et les lectures kana du japonais, AnkiConnect et l’extension Yomitan

* **Synthèse vocale** prend en charge de nombreux moteurs de synthèse en ligne ou hors ligne

* **Reconnaissance vocale** peut utiliser la reconnaissance vocale Windows sous Windows 10 et 11.

## Installation

Consultez Dans [LunaTranslator \: téléchargement, lancement et mise à jour](https\://docs.lunatranslator.org/zh/README.html) pour télécharger et installer.

## Connexion manuelle de LunaTranslator à SimiRouter

1. Dans SimiRouter, ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) pour copier la clé API souhaitée.
2. Dans LunaTranslator, ouvrez **Paramètres → Traduction → Grands modèles**, choisissez Ajouter et dupliquez le modèle d’interface générale pour créer une interface.
3. Ouvrez les paramètres de la nouvelle interface. Pour **Adresse de l’interface API** renseignez `https://api.dwchainless.com`, **API Key**, puis collez la clé. Actualisez la liste des modèles ou saisissez l’ID complet d’un modèle accessible au compte.
4. Enregistrez et activez l’interface. Traduisez un court texte non sensible, puis vérifiez l’appel dans les journaux SimiRouter.

Ne publiez pas la clé en capture. Les libellés peuvent varier selon la version ; consultez [Documentation officielle de LunaTranslator](https\://docs.lunatranslator.org/zh/guochandamoxing.html).