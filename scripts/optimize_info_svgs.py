#!/usr/bin/env python3
"""Conservative optimizer for info SVG assets.

Goals:
- keep visual output intact
- remove common editor metadata (Inkscape/Sodipodi attrs and metadata nodes)
- normalize XML output and UTF-8 encoding
- emit optimization report
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET


SVG_NS = "http://www.w3.org/2000/svg"
XMLNS = "{http://www.w3.org/2000/xmlns/}"
EDITOR_PREFIXES = ("{http://www.inkscape.org/namespaces/inkscape}", "{http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd}")
EDITOR_ATTR_PATTERNS = ("inkscape:", "sodipodi:")
REMOVE_TAGS = {
    "{http://www.w3.org/2000/svg}metadata",
    "{http://www.w3.org/2000/svg}title",
    "{http://www.w3.org/2000/svg}desc",
}


def strip_editor_attrs(elem: ET.Element) -> int:
    removed = 0
    for key in list(elem.attrib.keys()):
        if key.startswith(XMLNS):
            # keep xmlns declarations, cleanup is handled by ElementTree
            continue
        if key.startswith(EDITOR_PREFIXES) or key.startswith(EDITOR_ATTR_PATTERNS):
            elem.attrib.pop(key, None)
            removed += 1
    return removed


def prune_nodes(root: ET.Element) -> int:
    removed = 0
    for parent in list(root.iter()):
        for child in list(parent):
            if child.tag in REMOVE_TAGS:
                parent.remove(child)
                removed += 1
    return removed


def remove_doctype(raw: str) -> str:
    return re.sub(r"<!DOCTYPE[^>]*>\s*", "", raw, flags=re.IGNORECASE | re.MULTILINE)


def optimize_svg(path: Path) -> dict:
    before = path.stat().st_size
    raw = path.read_text(encoding="utf-8", errors="replace")
    raw = remove_doctype(raw)
    root = ET.fromstring(raw)
    if root.tag != f"{{{SVG_NS}}}svg" and not root.tag.endswith("svg"):
        raise ValueError("Root element is not <svg>")

    removed_attrs = 0
    for elem in root.iter():
        removed_attrs += strip_editor_attrs(elem)
    removed_nodes = prune_nodes(root)

    ET.register_namespace("", SVG_NS)
    out = ET.tostring(root, encoding="unicode", method="xml")
    out = '<?xml version="1.0" encoding="UTF-8"?>\n' + out + "\n"
    path.write_text(out, encoding="utf-8", newline="\n")
    after = path.stat().st_size
    return {
        "file": path.name,
        "before_bytes": before,
        "after_bytes": after,
        "delta_bytes": after - before,
        "removed_attrs": removed_attrs,
        "removed_nodes": removed_nodes,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--dir",
        default="assets/road_signs_info/svg",
        help="Directory containing SVG files",
    )
    parser.add_argument(
        "--report",
        default="assets/road_signs_info/optimize_report.json",
        help="Output JSON report path",
    )
    args = parser.parse_args()

    svg_dir = Path(args.dir)
    if not svg_dir.exists():
        raise FileNotFoundError(f"SVG dir not found: {svg_dir}")

    results = []
    failures = []
    total_before = 0
    total_after = 0

    for path in sorted(svg_dir.glob("*.svg")):
        try:
            result = optimize_svg(path)
            total_before += result["before_bytes"]
            total_after += result["after_bytes"]
            results.append(result)
        except Exception as exc:  # noqa: BLE001
            failures.append({"file": path.name, "error": str(exc)})

    report = {
        "count": len(results),
        "failed_count": len(failures),
        "total_before_bytes": total_before,
        "total_after_bytes": total_after,
        "total_delta_bytes": total_after - total_before,
        "results": results,
        "failures": failures,
    }
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"Optimized: {len(results)} SVGs")
    print(f"Failed: {len(failures)}")
    print(f"Total delta bytes: {report['total_delta_bytes']}")
    print(f"Report: {report_path}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
