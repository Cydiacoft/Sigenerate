#!/usr/bin/env python3
"""Classify SVGs by semantic type and complexity.

Outputs:
- JSON report with per-file metrics and buckets
- CSV priority list for optimization order
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import re
import statistics
import xml.etree.ElementTree as ET


CODE_RE = re.compile(r"路\s*([0-9]+)(?:[-_]?([0-9]+|[a-z]))?", re.IGNORECASE)


def extract_code_num(title: str) -> int | None:
    m = CODE_RE.search(title)
    if not m:
        return None
    try:
        return int(m.group(1))
    except ValueError:
        return None


def semantic_category(code_num: int | None, rules: dict) -> str:
    if code_num is None:
        return rules.get("fallback_semantic", "其他信息标志")
    for rule in rules.get("semantic_rules", []):
        if rule["min_code"] <= code_num <= rule["max_code"]:
            return rule["name"]
    return rules.get("fallback_semantic", "其他信息标志")


def compute_metrics(svg_path: Path) -> dict:
    raw = svg_path.read_text(encoding="utf-8", errors="replace")
    root = ET.fromstring(raw)
    elems = list(root.iter())
    path_elems = [e for e in elems if e.tag.endswith("path")]
    text_elems = [e for e in elems if e.tag.endswith("text")]
    g_elems = [e for e in elems if e.tag.endswith("g")]
    defs_elems = [e for e in elems if e.tag.endswith("defs")]

    total_path_chars = 0
    total_path_cmds = 0
    for p in path_elems:
        d = p.attrib.get("d", "")
        total_path_chars += len(d)
        total_path_cmds += sum(1 for c in d if c.isalpha())

    size = svg_path.stat().st_size
    score = (
        len(elems) * 1.0
        + len(path_elems) * 3.0
        + len(text_elems) * 2.0
        + total_path_cmds * 0.5
        + total_path_chars / 500.0
        + size / 5000.0
    )
    return {
        "file_size_bytes": size,
        "node_count": len(elems),
        "path_count": len(path_elems),
        "text_count": len(text_elems),
        "group_count": len(g_elems),
        "defs_count": len(defs_elems),
        "total_path_chars": total_path_chars,
        "total_path_cmds": total_path_cmds,
        "complexity_score": round(score, 3),
    }


def tertile_thresholds(scores: list[float]) -> tuple[float, float]:
    if not scores:
        return 0.0, 0.0
    sorted_scores = sorted(scores)
    n = len(sorted_scores)
    t1 = sorted_scores[max(0, int(n * 0.33) - 1)]
    t2 = sorted_scores[max(0, int(n * 0.66) - 1)]
    return t1, t2


def bucket(score: float, t1: float, t2: float) -> str:
    if score <= t1:
        return "简单"
    if score <= t2:
        return "中等"
    return "复杂"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        default="assets/road_signs_info/manifest.json",
    )
    parser.add_argument(
        "--svg-dir",
        default="assets/road_signs_info/svg",
    )
    parser.add_argument(
        "--rules",
        default="assets/road_signs_info/classification_rules.json",
    )
    parser.add_argument(
        "--out-json",
        default="assets/road_signs_info/classification_report.json",
    )
    parser.add_argument(
        "--out-csv",
        default="assets/road_signs_info/optimization_priority.csv",
    )
    args = parser.parse_args()

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8-sig"))
    if not isinstance(manifest, list):
        manifest = [manifest]
    rules = json.loads(Path(args.rules).read_text(encoding="utf-8-sig"))
    svg_dir = Path(args.svg_dir)

    rows = []
    scores = []
    for item in manifest:
        local = item["localFile"]
        title = item["title"]
        svg_path = svg_dir / local
        if not svg_path.exists():
            continue
        code_num = extract_code_num(title)
        metrics = compute_metrics(svg_path)
        scores.append(metrics["complexity_score"])
        rows.append(
            {
                "title": title,
                "localFile": local,
                "code_num": code_num,
                "semantic_category": semantic_category(code_num, rules),
                **metrics,
            }
        )

    t1, t2 = tertile_thresholds(scores)
    for row in rows:
        row["complexity_level"] = bucket(row["complexity_score"], t1, t2)

    rows.sort(
        key=lambda r: (
            0 if r["complexity_level"] == "复杂" else 1 if r["complexity_level"] == "中等" else 2,
            -r["complexity_score"],
        )
    )

    summary = {
        "total": len(rows),
        "thresholds": {"simple_max": t1, "medium_max": t2},
        "counts": {
            "简单": sum(1 for r in rows if r["complexity_level"] == "简单"),
            "中等": sum(1 for r in rows if r["complexity_level"] == "中等"),
            "复杂": sum(1 for r in rows if r["complexity_level"] == "复杂"),
        },
        "score_mean": round(statistics.mean(scores), 3) if scores else 0,
    }

    report = {"summary": summary, "items": rows}
    Path(args.out_json).write_text(
        json.dumps(report, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    with Path(args.out_csv).open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "priority",
                "complexity_level",
                "complexity_score",
                "semantic_category",
                "code_num",
                "localFile",
                "title",
                "node_count",
                "path_count",
                "total_path_cmds",
                "file_size_bytes",
            ]
        )
        for i, r in enumerate(rows, 1):
            writer.writerow(
                [
                    i,
                    r["complexity_level"],
                    r["complexity_score"],
                    r["semantic_category"],
                    r["code_num"],
                    r["localFile"],
                    r["title"],
                    r["node_count"],
                    r["path_count"],
                    r["total_path_cmds"],
                    r["file_size_bytes"],
                ]
            )

    print(f"Wrote {args.out_json}")
    print(f"Wrote {args.out_csv}")
    print("Summary:", summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
