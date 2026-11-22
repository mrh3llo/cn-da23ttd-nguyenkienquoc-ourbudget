"""Generate brand assets from the official SVG; run from any directory.

Install tool/requirements-brand.txt first. No runtime Flutter dependency.
"""
from copy import deepcopy
from io import BytesIO
import json
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image
from resvg_py import svg_to_bytes

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets/icons"
SVG = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG)
source = ET.parse(ASSETS / "our-budget-wordmark.svg").getroot()
circles = source.findall(f"{{{SVG}}}circle")
# Fail rather than silently extract a different mark after a source redesign.
assert len(circles) == 2
assert all(c.get("cx") == "16.8" and c.get("cy") == "21.6" for c in circles)
assert [c.get("r") for c in circles] == ["12.4", "8"]
outer_diameter = 2 * float(circles[0].get("r")) + float(circles[0].get("stroke-width"))


def mark(size, diameter):
    root = ET.Element(f"{{{SVG}}}svg", {
        "width": str(size), "height": str(size), "viewBox": f"0 0 {size} {size}",
    })
    group = ET.SubElement(root, f"{{{SVG}}}g", {
        "transform": f"translate({size / 2} {size / 2}) scale({diameter / outer_diameter}) translate(-16.8 -21.6)",
    })
    group.extend(deepcopy(c) for c in circles)
    assert [dict(c.attrib) for c in group] == [dict(c.attrib) for c in circles]
    return ET.tostring(root, encoding="unicode")


def png(path, svg, size=None, opaque=False):
    data = svg_to_bytes(svg_string=svg, width=size, background="#ffffff" if opaque else None)
    image = Image.open(BytesIO(data))
    if opaque:
        assert image.convert("RGBA").getchannel("A").getextrema() == (255, 255)
        image = image.convert("RGB")
    if size:
        assert image.size == (size, size)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


# Native 4x raster preserves the paths, proportions, colors and inner opacity.
wordmark = ET.tostring(source, encoding="unicode")
png(ASSETS / "our-budget-wordmark.png", wordmark)
high = ASSETS / "4.0x/our-budget-wordmark.png"
high.parent.mkdir(exist_ok=True)
high.write_bytes(svg_to_bytes(svg_string=wordmark, zoom=4))
icon = mark(1024, 1024 * 0.68)
(ASSETS / "our-budget-icon.svg").write_text(icon + "\n", encoding="utf-8")
png(ASSETS / "our-budget-icon.png", icon, 1024, opaque=True)

res = ROOT / "android/app/src/main/res"
for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    png(res / f"mipmap-{density}/ic_launcher.png", icon, size, opaque=True)

# Entire 60dp mark fits inside Android's central 66dp safe zone on 108dp layers.
png(res / "drawable-xxxhdpi/ic_launcher_foreground.png", mark(108, 60), 432)
adaptive = res / "mipmap-anydpi-v26/ic_launcher.xml"
adaptive.parent.mkdir(parents=True, exist_ok=True)
adaptive.write_text('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/white" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
''', encoding="utf-8")

catalog = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
contents = json.loads((catalog / "Contents.json").read_text(encoding="utf-8"))
for item in contents["images"]:
    size = round(float(item["size"].split("x")[0]) * float(item["scale"].rstrip("x")))
    png(catalog / item["filename"], icon, size, opaque=True)
assert any(i["size"] == "1024x1024" for i in contents["images"])
print("Generated wordmark, Android legacy/adaptive icons and all iOS AppIcon sizes.")
