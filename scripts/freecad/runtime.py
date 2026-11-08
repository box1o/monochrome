"""Shared CLI, logging, command execution and file writes for Mono Python tools."""

import argparse
import logging
import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("mono")


def parser(**kwargs):
    result = argparse.ArgumentParser(**kwargs)
    result.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        default=os.environ.get("SHELL_LIB_DRY_RUN") == "true",
    )
    return result


def run(command, *, dry_run=False, read_only=False, **kwargs):
    if dry_run and not read_only:
        log.info("DRY-RUN %s", shlex.join(command))
        return subprocess.CompletedProcess(command, 0, stdout="", stderr="")
    return subprocess.run(command, **kwargs)


def write_bytes(path, content, *, dry_run=False, backup=False):
    path = Path(path)
    if dry_run:
        log.info("DRY-RUN write %s", path)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    saved = path.with_name(path.name + ".mono-backup")
    if backup and path.exists() and not saved.exists():
        shutil.copy2(path, saved)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(content)
        temporary.replace(path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
