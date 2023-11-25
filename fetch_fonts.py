#!/usr/bin/env python3

import json
import pathlib
import tempfile
import urllib.request
import zipfile

PROJECT_NAME = "IBM/plex"
RELEASE_API_ENDPOINT = f"https://api.github.com/repos/{PROJECT_NAME}/releases/latest"

DESIRED_ASSET = "TrueType.zip"

FONT_SUBFOLDER = "TrueType"
FONT_DEST_DIR = pathlib.Path("/usr/local/share/fonts")

def get_latest_release_metadata() -> str:
    with urllib.request.urlopen(RELEASE_API_ENDPOINT) as resp:
        data = resp.read()
        encoding = resp.info().get_content_charset("utf-8")
        return data.decode(encoding)

def get_font_url() -> str:
    raw_metadata = get_latest_release_metadata()
    metadata = json.loads(raw_metadata)

    url = ""

    for release_asset in metadata["assets"]:
        if release_asset["name"] == DESIRED_ASSET:
            url = release_asset["browser_download_url"]

    if len(url) == 0:
        release_name = metadata["name"]
        errmsg = (
            f"Release {release_name} of {PROJECT_NAME} "
            f"did not contain asset '{DESIRED_ASSET}'"
        )
        raise Exception(errmsg)

    return url

if __name__ == "__main__":
    url = get_font_url()

    with tempfile.TemporaryDirectory(suffix="fonts") as tmp:
        temp_dir = pathlib.Path(tmp)
        download_path = temp_dir / DESIRED_ASSET
        font_temp_dir = temp_dir / FONT_SUBFOLDER

        print(f"Downloading {url}")
        urllib.request.urlretrieve(url, download_path)

        print(f"Extracting {download_path}")
        with zipfile.ZipFile(download_path, "r") as font_archive:
            font_archive.extractall(temp_dir)

        FONT_DEST_DIR.mkdir(exist_ok=True)
        for dir in font_temp_dir.iterdir():
            for file in dir.iterdir():
                if file.suffix == ".ttf":
                    dest_file = FONT_DEST_DIR / file.name
                    print(dest_file)
                    file.rename(dest_file)
