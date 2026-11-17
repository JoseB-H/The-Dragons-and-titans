#!/usr/bin/env python3
"""Exporta un commit limpio; crea y verifica el candidato Windows sin dependencias."""

import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import shutil
import struct
import subprocess
import tarfile
import tempfile
import zipfile


GODOT_VERSION = "4.6.3.stable.official.7d41c59c4"
PRESET = "Windows x86_64"


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def run(command, **kwargs):
    return subprocess.run(command, check=True, **kwargs)


def verify_package(folder):
    expected = {"DragonsAndTitans.exe", "DragonsAndTitans.pck", "LEEME.txt",
                "VERSION.json", "LICENCIAS-GODOT.txt", "SHA256SUMS.txt"}
    if {item.name for item in folder.iterdir()} != expected:
        raise ValueError("El paquete no contiene exactamente los seis archivos previstos")
    exe = (folder / "DragonsAndTitans.exe").read_bytes()
    pe_offset = struct.unpack_from("<I", exe, 0x3C)[0]
    if (exe[:2] != b"MZ" or exe[pe_offset:pe_offset + 4] != b"PE\0\0"
            or struct.unpack_from("<H", exe, pe_offset + 4)[0] != 0x8664):
        raise ValueError("El ejecutable no es PE Windows x86_64")
    with (folder / "DragonsAndTitans.pck").open("rb") as pack:
        if pack.read(4) != b"GDPC":
            raise ValueError("PCK Godot inválido")
    for line in (folder / "SHA256SUMS.txt").read_text().splitlines():
        digest, name = line.split("  ", 1)
        if name not in expected - {"SHA256SUMS.txt"} or sha256(folder / name) != digest:
            raise ValueError("Checksum inválido: " + name)
    if len((folder / "SHA256SUMS.txt").read_text().splitlines()) != 5:
        raise ValueError("Listado de checksums incompleto")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", required=True, help="Commit a exportar (se resuelve a SHA completo)")
    parser.add_argument("--templates", required=True, type=Path,
                        help="Directorio oficial con version.txt y windows_release_x86_64.exe")
    parser.add_argument("--output-dir", type=Path, default=Path("builds/t06"))
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    commit = subprocess.check_output(
        ["git", "rev-parse", "--verify", args.ref + "^{commit}"], cwd=repo, text=True).strip()
    godot = shutil.which(args.godot)
    if not godot:
        parser.error("Godot no encontrado")
    templates = args.templates.resolve()
    template = templates / "windows_release_x86_64.exe"
    if (templates / "version.txt").read_text().strip() != "4.6.3.stable" or not template.is_file():
        parser.error("Se requieren plantillas oficiales 4.6.3.stable para Windows release x86_64")
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    name = "DragonsAndTitans-v0.1-rc1-windows-x86_64-" + commit[:7]
    archive_path = output / (name + ".zip")
    if archive_path.exists():
        parser.error("El ZIP ya existe; usa un directorio nuevo para no reemplazarlo")

    with tempfile.TemporaryDirectory(prefix="dragons-windows-") as scratch:
        work = Path(scratch)
        source = work / "source"
        source.mkdir()
        archive = subprocess.check_output(["git", "archive", commit], cwd=repo)
        with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
            tar.extractall(source, filter="data")
        env = os.environ.copy()
        for key, directory in [("XDG_CACHE_HOME", "cache"), ("XDG_DATA_HOME", "data"),
                               ("XDG_CONFIG_HOME", "config")]:
            env[key] = str(work / directory)
            (work / directory).mkdir()
        installed = work / "data/godot/export_templates/4.6.3.stable"
        installed.mkdir(parents=True)
        shutil.copyfile(template, installed / template.name)
        shutil.copyfile(templates / "version.txt", installed / "version.txt")
        version = subprocess.check_output([godot, "--version"], env=env, text=True).strip()
        if version != GODOT_VERSION:
            raise ValueError("Versión Godot distinta: " + version)
        package = work / name
        package.mkdir()
        game = source / "game"
        commands = [[godot, "--headless", "--path", str(game), "--import"],
                    [godot, "--headless", "--path", str(game), "--export-release",
                     PRESET, str(package / "DragonsAndTitans.exe")]]
        with (output / (name + "-export.log")).open("w") as log:
            for command in commands:
                log.write("$ " + " ".join(command) + "\n")
                log.flush()
                run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        shutil.copyfile(source / "docs/entrega/LEEME-WINDOWS.txt", package / "LEEME.txt")
        shutil.copyfile(source / "docs/entrega/LICENCIAS-GODOT.txt", package / "LICENCIAS-GODOT.txt")
        manifest = {"version": "0.1-rc1", "source_commit": commit,
                    "godot": version, "platform": "Windows", "architecture": "x86_64",
                    "configuration": "release", "renderer": "gl_compatibility", "preset": PRESET,
                    "preset_sha256": sha256(game / "export_presets.cfg"),
                    "template_sha256": sha256(template), "exported_on": platform.system(),
                    "native_windows_tested": False, "human_laptop_tested": False}
        (package / "VERSION.json").write_text(json.dumps(manifest, indent=2) + "\n")
        checksums = [sha256(p) + "  " + p.name for p in sorted(package.iterdir())]
        (package / "SHA256SUMS.txt").write_text("\n".join(checksums) + "\n")
        verify_package(package)
        with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zipf:
            for path in sorted(package.iterdir()):
                zipf.write(path, name + "/" + path.name)
        extracted = work / "extracted"
        with zipfile.ZipFile(archive_path) as zipf:
            if zipf.testzip() is not None:
                raise ValueError("ZIP corrupto")
            zipf.extractall(extracted)
        verify_package(extracted / name)
        digest = sha256(archive_path)
        (output / (archive_path.name + ".sha256")).write_text(digest + "  " + archive_path.name + "\n")
        report = {"zip": archive_path.name, "zip_sha256": digest,
                  "zip_bytes": archive_path.stat().st_size, "manifest": manifest,
                  "files": [{"name": p.name, "bytes": p.stat().st_size, "sha256": sha256(p)}
                            for p in sorted(package.iterdir())],
                  "checks": {"zip_crc": True, "clean_extraction": True,
                             "file_sha256": True, "windows_pe_x86_64": True, "godot_pck_magic": True}}
        (output / (name + "-report.json")).write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
