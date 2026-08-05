from pathlib import Path
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"
SOURCE_ICON = ROOT / "assets" / "icon" / "droneatlas_icon.png"

index = WEB / "index.html"
if index.exists():
    text = index.read_text(encoding="utf-8")
    text = text.replace("<title>droneatlas</title>", "<title>DroneAtlas</title>")
    text = text.replace('content="droneatlas"', 'content="DroneAtlas"')
    text = text.replace(
        '<meta name="description" content="A new Flutter project.">',
        '<meta name="description" content="Apprendre les drones et la photogrammétrie par la simulation.">',
    )
    index.write_text(text, encoding="utf-8")

manifest_path = WEB / "manifest.json"
if manifest_path.exists():
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest.update({
        "name": "DroneAtlas",
        "short_name": "DroneAtlas",
        "description": "Académie interactive pour apprendre les drones et la photogrammétrie.",
        "background_color": "#06131F",
        "theme_color": "#00D1C7",
        "display": "standalone",
    })
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

if SOURCE_ICON.exists():
    shutil.copy2(SOURCE_ICON, WEB / "favicon.png")
    icons_dir = WEB / "icons"
    icons_dir.mkdir(parents=True, exist_ok=True)
    for name in ("Icon-192.png", "Icon-512.png", "Icon-maskable-192.png", "Icon-maskable-512.png"):
        prepared = ROOT / "tool" / "web_icons" / name
        shutil.copy2(prepared if prepared.exists() else SOURCE_ICON, icons_dir / name)

print("Configuration Web DroneAtlas appliquée.")
