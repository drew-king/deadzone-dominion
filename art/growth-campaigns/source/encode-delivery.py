from io import BytesIO
from pathlib import Path

from PIL import Image, ImageChops


root = Path(__file__).resolve().parent.parent
for category in ("factory", "defense", "pets"):
    for path in sorted((root / category).glob("*-1920x1080.png")):
        with Image.open(path) as source:
            if source.size != (1920, 1080):
                raise ValueError(f"Unexpected dimensions: {path.name}")
            if "A" in source.getbands() and source.getchannel("A").getextrema() != (255, 255):
                raise ValueError(f"Unexpected transparency: {path.name}")
            pixels = source.convert("RGB")

        buffer = BytesIO()
        pixels.save(buffer, format="PNG", optimize=True)
        delivery = buffer.getvalue()
        if len(delivery) >= 3_000_000:
            raise ValueError(f"File exceeds the delivery size target: {path.name}")
        with Image.open(BytesIO(delivery)) as verified:
            if ImageChops.difference(pixels, verified).getbbox():
                raise ValueError(f"PNG optimization changed pixels: {path.name}")
        path.write_bytes(delivery)
        print(f"{path.name} {len(delivery):,} bytes")
