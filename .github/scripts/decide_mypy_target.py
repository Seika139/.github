"""Decide whether mypy should run with '.' based on pyproject configuration."""

from __future__ import annotations

import argparse
import os
import pathlib
import tomllib
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Mapping


def load_pyproject(path: pathlib.Path) -> Mapping[str, Any] | None:
    if not path.exists():
        return None
    return tomllib.loads(path.read_text(encoding="utf-8"))


def has_explicit_files(config: Mapping[str, Any] | None) -> bool:
    if not config:
        return False
    tool = (config.get("tool") or {}).get("mypy") or {}
    files = tool.get("files")
    if files is None:
        return False
    if isinstance(files, str):
        return bool(files.strip())
    if isinstance(files, (list, tuple)):
        return any(bool(str(item).strip()) for item in files)
    return False


def decide_use_dot(pyproject: pathlib.Path) -> bool:
    config = load_pyproject(pyproject)
    return not has_explicit_files(config)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pyproject", default="pyproject.toml", help="Path to pyproject.toml"
    )
    args = parser.parse_args()

    use_dot = decide_use_dot(pathlib.Path(args.pyproject))

    output_line = f"use_dot={'true' if use_dot else 'false'}\n"
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with pathlib.Path(output_path).open("a", encoding="utf-8") as f:
            f.write(output_line)
    print(output_line.strip())


if __name__ == "__main__":
    main()
