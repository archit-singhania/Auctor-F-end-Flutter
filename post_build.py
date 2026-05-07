"""
post_build.py
-------------
Run this after every `flutter build web --release` to patch the output.

What it does:
1. Removes `serviceWorkerSettings` from flutter_bootstrap.js
2. Removes empty {} build entries from _flutter.buildConfig in flutter_bootstrap.js
   (empty entries cause the loader to silently fail on some browsers -> black screen)
3. Removes the landing/ subdirectory from build/web

Usage:
    flutter build web --release && python post_build.py && vercel --prod
"""

import json
import re
import shutil
from pathlib import Path

BUILD_WEB = Path(__file__).parent / "build" / "web"


def patch_flutter_bootstrap():
    bootstrap = BUILD_WEB / "flutter_bootstrap.js"
    if not bootstrap.exists():
        print(f"[SKIP] {bootstrap} not found")
        return

    text = bootstrap.read_text(encoding="utf-8")
    original = text

    # 1. Remove serviceWorkerSettings from _flutter.loader.load({...});
    text = re.sub(
        r"_flutter\.loader\.load\(\{[\s\S]*?\}\s*\);",
        "_flutter.loader.load({});",
        text,
    )

    # 2. Remove empty {} entries from the builds array in _flutter.buildConfig
    def clean_builds(match):
        try:
            config = json.loads(match.group(1))
            config["builds"] = [b for b in config["builds"] if b]  # drop empty {}
            return f"_flutter.buildConfig = {json.dumps(config, separators=(',', ':'))};"
        except Exception:
            return match.group(0)  # leave unchanged if parse fails

    text = re.sub(
        r"_flutter\.buildConfig = (\{.*?\});",
        clean_builds,
        text,
        flags=re.DOTALL,
    )

    if text == original:
        print("[OK] flutter_bootstrap.js — already clean")
    else:
        bootstrap.write_text(text, encoding="utf-8")
        print("[PATCHED] flutter_bootstrap.js — removed serviceWorkerSettings + empty builds")


def remove_landing_dir():
    landing = BUILD_WEB / "landing"
    if landing.exists():
        shutil.rmtree(landing)
        print("[REMOVED] build/web/landing/")
    else:
        print("[OK] build/web/landing/ — not present")


if __name__ == "__main__":
    print(f"Post-build patching: {BUILD_WEB}")
    patch_flutter_bootstrap()
    remove_landing_dir()
    print("Done. Now run: vercel --prod")
