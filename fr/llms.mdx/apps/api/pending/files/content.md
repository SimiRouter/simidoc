# Obtenir le contenu d’un fichier

Télécharger le contenu original d’un fichier OpenAI téléversé ou d’un résultat dont la lecture est autorisée.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

## Description de l’interface

* **Méthode** \: `GET`
* **Adresse API** \: `/v1/files/{file_id}/content`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: sans corps.

C’est une requête HTTP ordinaire attendant la fin du téléchargement, pas un flux SSE du modèle ni une tâche asynchrone. Ressource et clé doivent appartenir au même projet ; certains usages de fichiers n’autorisent pas la lecture du contenu.

## Paramètres de requête

| Paramètres | Type           | Obligatoire | Description                          |
| ---------- | -------------- | ----------- | ------------------------------------ |
| `file_id`  | string, chemin | Oui         | ID du fichier dans le projet OpenAI. |

## Valeur de retour

En cas de succès, la réponse contient les octets du fichier, pas un objet JSON avec `data`. Choisissez l’extension selon le format original et ne décodez pas du binaire en UTF-8. Une réponse d’erreur peut cependant être en JSON.

| Valeur           | Description                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| Statut HTTP      | Succès \: `200`.                                                                                              |
| Corps de réponse | Octets originaux ; analysez ligne par ligne les fichiers de résultats JSONL.                                  |
| Nom du fichier   | Avant de télécharger, utilisez [Obtenir les informations d’un fichier](/simidoc/fr/apps/api/pending/files/retrieve) pour consulter `filename`. |

## Exemples de code

Prérequis \: Python 3, Node.js 20+, curl ou Go 1.20+. Enregistrez chaque exemple dans son fichier `.py`, `.cjs`, `.sh`, `.go` puis exécutez-le.

Définissez `OPENAI_API_KEY` et `OPENAI_FILE_ID` ; définissez le chemin de sortie avec `OUTPUT_FILE`, par défaut `downloaded-file.bin`. Les exemples Python, Node.js et Go écrasent un fichier de même nom \: vérifiez la cible avant exécution. L’exemple curl refuse d’écraser une cible existante.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request
    from pathlib import Path

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")
    file_id = required("OPENAI_FILE_ID")
    file_id_encoded = urllib.parse.quote(file_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/files/{file_id_encoded}/content",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    output = Path(os.environ.get("OUTPUT_FILE", "downloaded-file.bin"))
    output.write_bytes(result)
    print(output)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");
      const file_id = required("OPENAI_FILE_ID");
      const fileId = encodeURIComponent(file_id);
      const response = await fetch(`https://api.openai.com/v1/files/${fileId}/content`, {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const output = process.env.OUTPUT_FILE || "downloaded-file.bin";
      await writeFile(output, Buffer.from(await response.arrayBuffer()));
      console.log(output);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${OPENAI_FILE_ID:?请设置 OPENAI_FILE_ID}"
    [[ "$OPENAI_FILE_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    download=$(mktemp)
    trap 'rm -f "$download"' EXIT
    curl "https://api.openai.com/v1/files/${OPENAI_FILE_ID}/content" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$download"
    # 仅在 HTTP 成功后发布文件；不覆盖已有输出。
    ln "$download" "${OUTPUT_FILE:-downloaded-file.bin}"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"fmt"
    	"io"
    	"log"
    	"net/http"
    	"net/url"
    	"os"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")
    	file_id := required("OPENAI_FILE_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/files/%s/content", url.PathEscape(file_id))
    	req, err := http.NewRequest("GET", target, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	output := os.Getenv("OUTPUT_FILE")
    	if output == "" {
    		output = "downloaded-file.bin"
    	}
    	check(os.WriteFile(output, result, 0600))
    	fmt.Println(output)
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

Voici les erreurs HTTP courantes de l’accès direct officiel OpenAI, pas l’état de prise en charge SimiRouter.

| Code HTTP     | Signification                                              | Traitement                                                                                                                                             |
| ------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `400`         | Paramètre, usage de fichier ou état de ressource incorrect | Lisez `error.message` et `error.param`, corrigez puis soumettez de nouveau.                                                                            |
| `401`         | Clé invalide ou absente                                    | Vérifiez la clé OpenAI et son projet.                                                                                                                  |
| `403`         | Accès au projet ou à la ressource interdit                 | Vérifiez les autorisations du projet, de l’organisation et du rôle.                                                                                    |
| `404`         | Fichier, tâche ou modèle introuvable                       | Vérifiez l’ID et utilisez la clé du projet propriétaire.                                                                                               |
| `429`         | Limitation de débit ou crédit insuffisant                  | Distinguez débit et crédit ; attendez progressivement pour le débit et ne répétez pas les soumissions en cas de crédit insuffisant.                    |
| `500` / `503` | Erreur serveur ou indisponibilité temporaire               | Conservez l’ID de requête ; avant de répéter une écriture, vérifiez si la ressource existe déjà pour éviter téléversements ou entraînements en double. |

Les réponses d’échec contiennent généralement `error.message`, `error.type`, `error.param` et `error.code` ; certains champs peuvent être vides.

## Références officielles

* [Obtenir le contenu d’un fichier OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/content)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)