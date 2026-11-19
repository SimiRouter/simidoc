#!/usr/bin/env bash
# SimiRouter Codex setup. Uses the same API key for inference and model discovery.
set -Eeuo pipefail
set +x 2>/dev/null || true
umask 077
VERSION=1.2.0
INFERENCE_BASE_URL=https://api.dwchainless.com/v1
MODEL_CATALOG_URL=https://api.dwchainless.com/v1/models
CODEX_DIR="${CODEX_HOME:-${HOME:?HOME is not set}/.codex}"
CONFIG="$CODEX_DIR/config.toml"
MODELS="$CODEX_DIR/models.json"
CATALOG_VALUE="$MODELS"
BACKUPS="$CODEX_DIR/backup-simirouter"
LOCK="$CODEX_DIR/.simirouter-config.lock"
PY="$(command -v python3 || true)"
die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 0 ]] || die 'This script does not accept arguments.'
[[ -n "$PY" ]] || die 'Python 3.11+ with tomllib is required.'
"$PY" -c 'import sys,tomllib; assert sys.version_info >= (3,11)' 2>/dev/null || die 'Python 3.11+ with tomllib is required.'
if [[ -e "$CODEX_DIR" ]]; then [[ -d "$CODEX_DIR" ]] || die 'CODEX_HOME is not a directory.'; else mkdir -p "$CODEX_DIR"; chmod 700 "$CODEX_DIR"; fi
mkdir "$LOCK" 2>/dev/null || die "Another setup process is running (or stale lock: $LOCK)"
printf '%s\n' "$$" > "$LOCK/pid"; chmod 600 "$LOCK/pid"
trap 'rm -f "$LOCK/pid"; rmdir "$LOCK" 2>/dev/null || true' EXIT
ask(){ [[ -t 0 && -r /dev/tty ]] || die 'An interactive terminal is required.'; printf '%s' "$1" >/dev/tty; IFS= read -r REPLY </dev/tty || true; }
secret(){ [[ -t 0 && -r /dev/tty ]] || die 'A terminal is required for hidden key input.'; IFS= read -r -s -p "$1" REPLY </dev/tty || true; printf '\n' >/dev/tty; }
snapshot(){ local kind=$1 stamp tmp final; mkdir -p "$BACKUPS"; chmod 700 "$BACKUPS"; stamp=$(date -u +%Y%m%dT%H%M%S%NZ); final="$BACKUPS/$stamp"; [[ ! -e "$final" ]] || final="$final-$$"; tmp="$BACKUPS/.tmp.$$.${RANDOM}"; mkdir "$tmp"; if [[ -f "$CONFIG" ]]; then cp -p "$CONFIG" "$tmp/config.toml"; chmod 600 "$tmp/config.toml"; else : > "$tmp/config.toml.absent"; chmod 600 "$tmp/config.toml.absent"; fi; if [[ -f "$MODELS" ]]; then cp -p "$MODELS" "$tmp/models.json"; chmod 600 "$tmp/models.json"; else : > "$tmp/models.json.absent"; chmod 600 "$tmp/models.json.absent"; fi; printf 'version=%s\ncreated_at=%s\nkind=%s\ninference_base_url=%s\nmodel_catalog_url=%s\n' "$VERSION" "$stamp" "$kind" "$INFERENCE_BASE_URL" "$MODEL_CATALOG_URL" > "$tmp/manifest.txt"; chmod 600 "$tmp/manifest.txt"; mv "$tmp" "$final"; printf '%s' "$final"; }
find_backup(){ local n=$1 p; if [[ -n "$n" ]]; then [[ "$n" =~ ^[A-Za-z0-9_.-]+$ ]] || die 'Invalid backup name.'; p="$BACKUPS/$n"; else p=$(find "$BACKUPS" -mindepth 1 -maxdepth 1 -type d ! -name '.tmp.*' -print 2>/dev/null|sort|tail -n1); fi; [[ -d "$p" && -f "$p/manifest.txt" ]] || die 'Backup snapshot not found.'; printf '%s' "$p"; }
current_token(){ [[ -f "$CONFIG" ]] || return 0; "$PY" - "$CONFIG" <<'PY'
import sys,tomllib
with open(sys.argv[1],'rb') as f:d=tomllib.load(f)
v=d.get('model_providers',{}).get('simirouter',{}).get('experimental_bearer_token','')
if isinstance(v,str):sys.stdout.write(v)
PY
}
fetch_models(){ local token=$1 path=$2; "$PY" - "$MODEL_CATALOG_URL" "$path" 3<<<"$token" <<'PY'
import json,sys,urllib.request
from pathlib import Path
url,path=sys.argv[1:3]
token=sys.stdin.read() if False else __import__('os').fdopen(3,'rb').read().decode('utf-8').rstrip('\n')
req=urllib.request.Request(url,headers={'Accept':'application/json','Authorization':f'Bearer {token}'})
try:
    with urllib.request.urlopen(req,timeout=30) as response:
        payload=json.load(response)
except Exception as exc:
    raise SystemExit(f'model catalog request failed: {exc}')
rows=payload.get('data') if isinstance(payload,dict) else None
if not isinstance(rows,list) or not rows:
    raise SystemExit('model catalog response must contain a non-empty data array')
models=[]
seen=set()
for index,row in enumerate(rows):
    if not isinstance(row,dict) or not isinstance(row.get('id'),str) or not row['id'].strip():
        continue
    slug=row['id'].strip()
    if slug in seen:
        continue
    seen.add(slug)
    model={'slug':slug,'display_name':row.get('name') or slug,'description':f"SimiRouter model ({row.get('owned_by','provider')})",'supported_reasoning_levels':[],'shell_type':'shell_command','visibility':'list','supported_in_api':True,'priority':len(models),'support_verbosity':False,'truncation_policy':{'mode':'tokens','limit':10000}}
    context=row.get('context_length')
    if isinstance(context,int) and context>0:
        model['context_window']=context; model['max_context_window']=context
    models.append(model)
if not models:
    raise SystemExit('model catalog did not contain usable model IDs')
Path(path).write_text(json.dumps({'models':models},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
PY
}
validate_model(){ local path=$1 model=$2; "$PY" - "$path" "$model" <<'PY'
import json,sys
path,selected=sys.argv[1:3]
with open(path,encoding='utf-8') as f: payload=json.load(f)
ids=[row.get('slug') for row in payload.get('models',[]) if isinstance(row,dict) and isinstance(row.get('slug'),str)]
if selected not in ids:
    available=', '.join(ids[:20]) or '(none)'
    raise SystemExit(f"selected model '{selected}' is not in the fetched catalog: {available}")
PY
}
write_config(){ local path=$1 model=$2 token=$3; SIMI_BASE="$INFERENCE_BASE_URL" SIMI_MODEL="$model" SIMI_CATALOG="$CATALOG_VALUE" "$PY" - "$path" 3<<<"$token" <<'PY'
import copy,json,os,re,sys,tomllib
from pathlib import Path
p=Path(sys.argv[1]); token=os.fdopen(3,'rb').read().decode('utf-8'); token=token[:-1] if token.endswith('\n') else token; model=os.environ['SIMI_MODEL']; base=os.environ['SIMI_BASE']; catalog=os.environ['SIMI_CATALOG']
if '\n' in token or '\r' in token: raise ValueError('API key cannot contain a newline')
s=p.read_text(encoding='utf-8') if p.exists() else ''; before=tomllib.loads(s) if s.strip() else {}
m={'name':'name = "simirouter"\n','base_url':f'base_url = {json.dumps(base,ensure_ascii=False)}\n','wire_api':'wire_api = "responses"\n','supports_websockets':'supports_websockets = false\n','experimental_bearer_token':f'experimental_bearer_token = {json.dumps(token,ensure_ascii=False)}\n'}; keys=set(m); out=[]; sec=None; inside=False; seen=set(); globals=set()
def key(x):
 q=re.match(r'^\s*([A-Za-z0-9_-]+)\s*=',x); return q.group(1) if q else None
for line in s.splitlines(keepends=True):
 h=re.match(r'^\s*\[([^]]+)\]',line)
 if h:
  if inside: out.extend(m[k] for k in m if k not in seen)
  sec=h.group(1).strip(); inside=sec.lower()=='model_providers.simirouter'; seen=set(); out.append('[model_providers.simirouter]\n' if inside else line); continue
 if inside:
  k=key(line)
  if k in keys:
   if k not in seen: seen.add(k); out.append(m[k])
   continue
  out.append(line); continue
 if sec is None:
  k=key(line)
  if k=='model_provider':
   if k not in globals: globals.add(k); out.append('model_provider = "simirouter"\n')
   continue
  if sec is None and k=='model_catalog_json':
   if k not in globals: globals.add(k); out.append(f'model_catalog_json = {json.dumps(catalog,ensure_ascii=False)}\n')
   continue
  if k=='model':
   if k not in globals: globals.add(k); out.append(f'model = {json.dumps(model,ensure_ascii=False)}\n')
   continue
 out.append(line)
if inside: out.extend(m[k] for k in m if k not in seen)
elif not any(re.match(r'^\s*\[model_providers\.simirouter\]',x,re.I) for x in out): out += ['\n','[model_providers.simirouter]\n',*m.values()]
prefix=[]
if 'model_provider' not in globals: prefix.append('model_provider = "simirouter"\n')
if 'model' not in globals: prefix.append(f'model = {json.dumps(model,ensure_ascii=False)}\n')
if 'model_catalog_json' not in globals: prefix.append(f'model_catalog_json = {json.dumps(catalog,ensure_ascii=False)}\n')
text=''.join(prefix+out); after=tomllib.loads(text)
def scrub(d):
 d=copy.deepcopy(d); d.pop('model_provider',None); d.pop('model',None); d.pop('model_catalog_json',None); ps=d.get('model_providers')
 if isinstance(ps,dict):
  for n in list(ps):
   if n.lower()=='simirouter' and isinstance(ps[n],dict):
    for k in keys: ps[n].pop(k,None)
    if not ps[n]: ps.pop(n,None)
  if not ps:d.pop('model_providers',None)
 return d
want={'name':'simirouter','base_url':base,'wire_api':'responses','supports_websockets':False,'experimental_bearer_token':token}; got=after.get('model_providers',{}).get('simirouter',{})
if any(got.get(k)!=v for k,v in want.items()) or scrub(before)!=scrub(after): raise ValueError('semantic validation failed')
p.write_text(text,encoding='utf-8')
PY
}
configure(){ local model token old backup tmp models_tmp; printf '%s\n' 'SimiRouter inference URL: '"$INFERENCE_BASE_URL" 'SimiRouter model catalog URL: '"$MODEL_CATALOG_URL" 'Model 1: gpt-6-astra (must be available in the catalog)' 'Model 2: custom model ID'; ask 'Choose model [1/2] (default 1): '; case "$REPLY" in ''|1)model=gpt-6-astra;;2)ask 'Model ID: ';model=$REPLY;[[ -n "$model"&&"$model" != *$'\n'* ]]||die 'Invalid model ID.';;*)die 'Invalid model choice.';;esac; old=$(current_token)||die 'Existing config.toml is invalid.'; secret 'SimiRouter API key (used for both URLs; leave blank to keep current): '; token=$REPLY; [[ "$token" != *$'\n'* ]]||die 'API key cannot contain a newline.'; [[ -n "$token" ]]||token=$old; [[ -n "$token" ]]||die 'API key is required for first-time setup.'; models_tmp="$CODEX_DIR/.models.json.stage.$$.${RANDOM}"; fetch_models "$token" "$models_tmp" || { rm -f "$models_tmp"; die 'Model catalog could not be fetched; original files were kept.'; }; chmod 600 "$models_tmp"; validate_model "$models_tmp" "$model" || { rm -f "$models_tmp"; die 'Selected model is not available in the fetched catalog; original files were kept.'; }; tmp="$CODEX_DIR/.config.toml.stage.$$.${RANDOM}"; if [[ -f "$CONFIG" ]]; then cp "$CONFIG" "$tmp"; else : > "$tmp"; fi; chmod 600 "$tmp"; write_config "$tmp" "$model" "$token"||{ rm -f "$tmp" "$models_tmp";die 'Generated config.toml failed validation; original was kept.';}; chmod 600 "$tmp"; backup=$(snapshot before-configure); if ! mv -f "$tmp" "$CONFIG" || ! mv -f "$models_tmp" "$MODELS"; then rm -f "$tmp" "$models_tmp"; if [[ -f "$backup/config.toml" ]]; then cp -p "$backup/config.toml" "$CONFIG"; else rm -f "$CONFIG"; fi; if [[ -f "$backup/models.json" ]]; then cp -p "$backup/models.json" "$MODELS"; else rm -f "$MODELS"; fi; chmod 600 "$CONFIG" "$MODELS" 2>/dev/null || true; die 'Could not replace config.toml and models.json; original files were restored.'; fi; chmod 600 "$CONFIG" "$MODELS"; printf 'Configured %s. Model catalog: %s. Backup: %s\n' "$model" "$MODELS" "$backup"; }
restore(){
 local n b old config_tmp models_tmp
 ask 'Backup name (blank = latest): '; n=$REPLY; b=$(find_backup "$n")
 ask "Type RESTORE to restore $(basename "$b"): "
 [[ "$REPLY" == RESTORE ]] || { printf 'Restore cancelled.\n'; return; }
 old=$(snapshot before-restore)
 config_tmp="$CODEX_DIR/.config.toml.restore.$$.${RANDOM}"
 models_tmp="$CODEX_DIR/.models.json.restore.$$.${RANDOM}"
 if [[ -f "$b/config.toml" ]]; then
   cp "$b/config.toml" "$config_tmp"; chmod 600 "$config_tmp"
   "$PY" -c 'import sys,tomllib; tomllib.load(open(sys.argv[1],"rb"))' "$config_tmp" >/dev/null || { rm -f "$config_tmp" "$models_tmp"; die 'Backup config.toml is invalid; current state was kept.'; }
 elif [[ ! -f "$b/config.toml.absent" ]]; then
   die 'Backup snapshot has no config state.'
 fi
 if [[ -f "$b/models.json" ]]; then
   cp "$b/models.json" "$models_tmp"; chmod 600 "$models_tmp"
   "$PY" -c 'import json,sys; d=json.load(open(sys.argv[1])); assert isinstance(d.get("models"),list) and d["models"]' "$models_tmp" >/dev/null || { rm -f "$config_tmp" "$models_tmp"; die 'Backup models.json is invalid; current state was kept.'; }
 elif [[ ! -f "$b/models.json.absent" ]]; then
   rm -f "$MODELS" # Backups created before v1.2.0 did not contain a model catalog.
 fi
 if [[ -f "$config_tmp" ]]; then mv -f "$config_tmp" "$CONFIG"; else rm -f "$CONFIG"; fi
 if [[ -f "$models_tmp" ]]; then mv -f "$models_tmp" "$MODELS"; else rm -f "$MODELS"; fi
 chmod 600 "$CONFIG" "$MODELS" 2>/dev/null || true
 printf 'Restored %s. Current state backed up at %s.\n' "$(basename "$b")" "$(basename "$old")"
}
printf 'SimiRouter Codex setup %s\nCODEX_HOME: %s\n1) Configure SimiRouter\n2) Restore a backup\nq) Exit\n' "$VERSION" "$CODEX_DIR"; ask 'Choose [1/2/q]: '; case "$REPLY" in 1)configure;;2)[[ -d "$BACKUPS" ]]||die 'No backup snapshots found.';restore;;q|Q|'')printf 'Cancelled.\n';;*)die 'Invalid choice.';;esac
