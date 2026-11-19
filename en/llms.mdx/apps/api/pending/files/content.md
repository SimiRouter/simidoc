# Retrieve file content

Download raw OpenAI file contents for readable uploads or output files.

**SimiRouter does not currently support this endpoint. The following references the official OpenAI API at `api.openai.com` and requires a key for the OpenAI project, not a SimiRouter key.**

## Endpoint overview

* **Method**\: `GET`
* **Endpoint address**\: `/v1/files/{file_id}/content`
* **Authentication**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Request type**\: no request body.

This ordinary HTTP request waits for the download to finish; it is neither model SSE nor an asynchronous task. The key must match the resource’s project, and not every file purpose permits content retrieval.

## Request parameters

| Parameters | Type         | Required | Description                      |
| ---------- | ------------ | -------- | -------------------------------- |
| `file_id`  | string, path | Yes      | A file ID in the OpenAI project. |

## Response

A successful response is file bytes, not a JSON object containing `data`. Choose the extension for the original file format; do not decode binary content as UTF-8. Error responses may still be JSON.

| Content       | Description                                                                          |
| ------------- | ------------------------------------------------------------------------------------ |
| HTTP status   | Success is `200`.                                                                    |
| Response body | Raw file bytes; parse JSONL result files line by line.                               |
| Filename      | Before downloading, use [Retrieve file information](/simidoc/en/apps/api/pending/files/retrieve) to query `filename`. |

## Code examples

Requirements\: Python 3, Node.js 20+, curl, or Go 1.20+. Save each language example as a `.py`, `.cjs`, `.sh`, `.go` file, then run it.

Set `OPENAI_API_KEY` and `OPENAI_FILE_ID`; use `OUTPUT_FILE` to specify an output path, default `downloaded-file.bin`. Python, Node.js, and Go examples overwrite matching output files; verify the destination before running. The curl example refuses to overwrite an existing target.

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

## Errors

The following are common HTTP errors from direct official OpenAI requests, not SimiRouter support statuses.

| HTTP status   | Meaning                                             | Action                                                                                                                      |
| ------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `400`         | Invalid parameters, file purpose, or resource state | Read `error.message` and `error.param` and correct the issue before resubmitting.                                           |
| `401`         | Invalid or missing key                              | Check the OpenAI key and its project.                                                                                       |
| `403`         | No access to the project or resource                | Check project, organization, and role permissions.                                                                          |
| `404`         | File, job, or model not found                       | Verify the ID and use a key belonging to the resource’s project.                                                            |
| `429`         | Rate limit or insufficient quota                    | Distinguish rate limits from quota errors; back off for rate limits, but do not repeatedly submit with insufficient quota.  |
| `500` / `503` | Server error or temporarily unavailable             | Retain the request ID. Before retrying writes, check whether a resource was created to avoid duplicate uploads or training. |

Unsuccessful responses usually contain `error.message`, `error.type`, `error.param` and `error.code`; fields may be empty.

## Official reference

* [OpenAI retrieve file content](https\://developers.openai.com/api/reference/resources/files/methods/content)
* [OpenAI error codes](https\://developers.openai.com/api/docs/guides/error-codes)