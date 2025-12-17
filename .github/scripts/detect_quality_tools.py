"""Detect optional quality tools from pyproject dependencies and emit GitHub outputs."""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import tomllib  # このモジュールは Python 3.11 以降で利用可能です。
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Mapping


def normalize(dep: str) -> str | None:
    match = re.match(r"([A-Za-z0-9_.-]+)", dep.strip())
    return match.group(1).lower() if match else None


def collect_dependencies(data: Mapping[str, Any]) -> set[str]:
    deps: list[str] = []

    project = data.get("project", {}) or {}
    deps.extend(project.get("dependencies", []) or [])
    for extra in (project.get("optional-dependencies") or {}).values():
        deps.extend(extra or [])

    for group in (data.get("dependency-groups") or {}).values():
        deps.extend(group or [])

    return {d for d in (normalize(dep) for dep in deps) if d}


def detect_tools(pyproject_path: pathlib.Path) -> dict[str, bool]:
    tools = {"ruff": False, "mypy": False, "pytest": False}

    if not pyproject_path.exists():
        print(f"{pyproject_path} not found; disabling all quality tools")
        return tools

    data = tomllib.loads(pyproject_path.read_text(encoding="utf-8"))
    normalized = collect_dependencies(data)

    for name in tools:
        tools[name] = name in normalized

    return tools


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pyproject", default="pyproject.toml", help="Path to pyproject.toml"
    )
    args = parser.parse_args()

    tools = detect_tools(pathlib.Path(args.pyproject))

    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with pathlib.Path(output_path).open("a", encoding="utf-8") as f:
            f.writelines(
                f"{key}={'true' if value else 'false'}\n"
                for key, value in tools.items()
            )

    print("Detected tools:", json.dumps(tools))


if __name__ == "__main__":
    main()
