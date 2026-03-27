import argparse
import json
import os
import time
import urllib.error
import urllib.parse
import urllib.request

WIKIMEDIA_API = "https://commons.wikimedia.org/w/api.php"
DEFAULT_OUTPUT = "D:/road_creator/assets/road_signs/china"

# Curated first batch for current editor needs.
# Source catalog: https://commons.wikimedia.org/wiki/Road_signs_in_China
SIGNS = {
    "warning": [
        ("warn-crossroad", "CN_road_sign_警告_1-1.svg", "交叉路口"),
        ("warn-pedestrian", "CN_road_sign_警告_10-1.svg", "注意行人"),
        ("warn-children", "CN_road_sign_警告_11-1.svg", "注意儿童"),
        ("warn-work", "CN_road_sign_警告_36.svg", "施工"),
        ("warn-sharp-left", "CN_road_sign_警告_2-1.svg", "向左急弯路"),
        ("warn-sharp-right", "CN_road_sign_警告_2-2.svg", "向右急弯路"),
        ("warn-slippery", "China_road_sign_警告_17.svg", "易滑"),
    ],
    "prohibition": [
        ("pro-stop", "CN_road_sign_禁令_1.svg", "停车让行"),
        ("pro-yield", "CN_road_sign_禁令_2.svg", "减速让行"),
        ("pro-no-entry", "CN_road_sign_禁令_5.svg", "禁止驶入"),
        ("pro-no-left-turn", "China_road_sign_禁令_22.svg", "禁止向左转弯"),
        ("pro-no-right-turn", "China_road_sign_禁令_23.svg", "禁止向右转弯"),
        ("pro-no-straight", "CN_road_sign_禁令_24.svg", "禁止直行"),
        ("pro-no-uturn", "CN_road_sign_禁令_28.svg", "禁止掉头"),
        ("pro-no-parking", "CN_road_sign_禁令_32.svg", "禁止长时停车"),
        ("pro-no-honking", "CN_road_sign_禁令_33.svg", "禁止鸣喇叭"),
    ],
    "mandatory": [
        ("man-straight", "CN_road_sign_指示_1.svg", "直行"),
        ("man-left", "CN_road_sign_指示_2.svg", "向左转弯"),
        ("man-right", "CN_road_sign_指示_3.svg", "向右转弯"),
        ("man-straight-left", "CN_road_sign_指示_4.svg", "直行和向左转弯"),
        ("man-straight-right", "CN_road_sign_指示_5.svg", "直行和向右转弯"),
        ("man-keep-right", "CN_road_sign_指示_7.svg", "靠右侧道路行驶"),
        ("man-keep-left", "CN_road_sign_指示_8.svg", "靠左侧道路行驶"),
        ("man-roundabout", "CN_road_sign_指示_9.svg", "环岛行驶"),
    ],
    "information": [
        ("info-expressway", "China_road_sign_高速公路.svg", "高速公路"),
        ("info-service", "China_road_sign_服务区.svg", "服务区"),
        ("info-tourist", "China_road_sign_旅游区.svg", "旅游区"),
    ],
}


def _request_json(url: str) -> dict:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "RoadCreator/1.0 (Wikimedia downloader)"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def get_file_original_url(filename: str) -> str | None:
    title = f"File:{filename}"
    query = urllib.parse.urlencode(
        {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "titles": title,
            "iiprop": "url|mime",
            "redirects": "1",
        }
    )
    url = f"{WIKIMEDIA_API}?{query}"
    data = _request_json(url)
    pages = data.get("query", {}).get("pages", {})
    if not pages:
        return None
    page = next(iter(pages.values()))
    info = page.get("imageinfo")
    if not info:
        return None
    mime = info[0].get("mime", "")
    if mime != "image/svg+xml":
        return None
    return info[0].get("url")


def download_file(url: str, output_path: str) -> bool:
    req = urllib.request.Request(
        url, headers={"User-Agent": "RoadCreator/1.0 (Wikimedia downloader)"}
    )
    try:
        with urllib.request.urlopen(req, timeout=40) as resp:
            content = resp.read()
        if b"<svg" not in content[:400]:
            return False
        with open(output_path, "wb") as f:
            f.write(content)
        return True
    except (urllib.error.URLError, TimeoutError):
        return False


def run(output_root: str, overwrite: bool, delay: float) -> tuple[int, int]:
    total = 0
    success = 0
    os.makedirs(output_root, exist_ok=True)

    for category, signs in SIGNS.items():
        category_dir = os.path.join(output_root, category)
        os.makedirs(category_dir, exist_ok=True)

        for sign_id, filename, label in signs:
            total += 1
            output_path = os.path.join(category_dir, f"{sign_id}.svg")
            if os.path.exists(output_path) and not overwrite:
                print(f"[SKIP] {sign_id} {label} (exists)")
                success += 1
                continue

            print(f"[GET ] {sign_id} {label} ... ", end="")
            original_url = get_file_original_url(filename)
            if not original_url:
                print("NO_URL")
                time.sleep(delay)
                continue

            if download_file(original_url, output_path):
                print("OK")
                success += 1
            else:
                print("FAILED")
            time.sleep(delay)

    return total, success


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download selected China road sign SVGs from Wikimedia Commons."
    )
    parser.add_argument("--output", default=DEFAULT_OUTPUT, help="Output directory")
    parser.add_argument(
        "--overwrite", action="store_true", help="Overwrite existing SVG files"
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.2,
        help="Sleep seconds between requests (default: 0.2)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    total, success = run(
        output_root=args.output, overwrite=args.overwrite, delay=args.delay
    )
    print(f"\nDone. total={total}, success={success}, failed={total - success}")


if __name__ == "__main__":
    main()
