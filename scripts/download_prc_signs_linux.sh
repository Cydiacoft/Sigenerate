#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/svg"
MANIFEST_PATH="${SCRIPT_DIR}/manifest.json"

mkdir -p "${OUT_DIR}"

python3 - <<'PY'
import json
import os
import time
import urllib.parse
import urllib.request

OUT_DIR = os.environ.get("OUT_DIR")
MANIFEST_PATH = os.environ.get("MANIFEST_PATH")

API = "https://commons.wikimedia.org/w/api.php"
CATEGORY = "Category:SVG_information_road_signs_of_China"

def fetch_json(url):
    with urllib.request.urlopen(url, timeout=120) as resp:
        return json.loads(resp.read().decode("utf-8"))

def build_query(params):
    return urllib.parse.urlencode(params)

def sanitize_filename(title):
    name = title.replace("File:", "").strip()
    name = "_".join(name.split())
    for ch in '<>:"/\\|?*':
        name = name.replace(ch, "")
    return name

def is_svg(path):
    try:
        with open(path, "rb") as f:
            head = f.read(2048).decode("utf-8", errors="ignore")
        return "<svg" in head or "<?xml" in head
    except Exception:
        return False

def download_with_retry(url, out_path, retries=6):
    attempt = 0
    headers = {
        "User-Agent": "SigeneratorAssetFetcher/1.0",
        "Accept": "image/svg+xml",
    }
    while True:
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=120) as resp:
                data = resp.read()
            with open(out_path, "wb") as f:
                f.write(data)
            if not is_svg(out_path):
                os.remove(out_path)
                raise RuntimeError("Invalid SVG content")
            return
        except Exception as e:
            attempt += 1
            if attempt >= retries:
                raise
            time.sleep(min(60, 2 ** attempt))

def list_files():
    files = []
    cmcontinue = None
    while True:
        params = {
            "action": "query",
            "list": "categorymembers",
            "cmtitle": CATEGORY,
            "cmtype": "file",
            "cmlimit": 500,
            "format": "json",
        }
        if cmcontinue:
            params["cmcontinue"] = cmcontinue
        url = API + "?" + build_query(params)
        resp = fetch_json(url)
        files.extend(resp.get("query", {}).get("categorymembers", []))
        cmcontinue = resp.get("continue", {}).get("cmcontinue")
        if not cmcontinue:
            break
    return files

def main():
    out_dir = OUT_DIR
    manifest = []
    files = list_files()
    total = len(files)
    for idx, item in enumerate(files, 1):
        title = item.get("title")
        if not title:
            continue
        file_name = sanitize_filename(title)
        local_path = os.path.join(out_dir, file_name)
        # avoid overwrite
        base, ext = os.path.splitext(file_name)
        suffix = 1
        while os.path.exists(local_path):
            if is_svg(local_path):
                break
            file_name = f"{base}_{suffix}{ext}"
            local_path = os.path.join(out_dir, file_name)
            suffix += 1
        if os.path.exists(local_path) and is_svg(local_path):
            print(f"[{idx}/{total}] {file_name} (cached)")
        else:
            encoded = urllib.parse.quote(file_name)
            url = f"https://commons.wikimedia.org/wiki/Special:FilePath/{encoded}"
            print(f"[{idx}/{total}] {file_name}")
            download_with_retry(url, local_path)
            time.sleep(2)
        manifest.append({
            "title": title,
            "localFile": file_name,
            "sourceUrl": f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(file_name)}",
        })
    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"Saved manifest to {MANIFEST_PATH}")

if __name__ == "__main__":
    main()

PY
