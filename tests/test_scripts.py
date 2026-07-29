# ruff:file-ignore[assert, private-member-access]
from __future__ import annotations

import sys
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

import decide_mypy_target
import detect_quality_tools
import determine_next_version
import pytest
import update_changelog
import update_pyproject_version
import update_readme_version


def test_update_changelog_initial_release(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("GITHUB_REPOSITORY", "owner/repo")
    changelog = """# CHANGELOG

## Tagged Releases

## [Unreleased]
"""
    updated = update_changelog._update_tagged_releases(changelog, "0.1.0")

    assert (
        "- [unreleased](https://github.com/owner/repo/compare/v0.1.0...HEAD)\n"
        in updated
    )
    assert "- [0.1.0](https://github.com/owner/repo/releases/tag/v0.1.0)\n" in updated


def test_update_changelog_existing_entries() -> None:
    changelog = """## Tagged Releases
- [unreleased](https://github.com/owner/repo/compare/v0.1.0...HEAD)
- [0.1.0](https://github.com/owner/repo/compare/v0.0.1...v0.1.0)

## [Unreleased]
"""
    updated = update_changelog._update_tagged_releases(changelog, "0.1.1")
    assert (
        "- [0.1.1](https://github.com/owner/repo/compare/v0.1.0...v0.1.1)\n" in updated
    )


def test_update_pyproject_version(tmp_path: Path) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text('version = "0.1.0"\n', encoding="utf-8")

    update_pyproject_version.update_version(pyproject, "0.2.0")

    assert pyproject.read_text(encoding="utf-8").strip() == 'version = "0.2.0"'


@pytest.mark.parametrize(
    ("current", "bump", "expected"),
    [
        ("0.1.0", "patch", "0.1.1"),
        ("0.1.0", "minor", "0.2.0"),
        ("0.1.0", "major", "1.0.0"),
    ],
)
def test_determine_next_version(current: str, bump: str, expected: str) -> None:
    assert determine_next_version.bump_version(current, bump) == expected


def test_decide_mypy_target(tmp_path: Path) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text(
        """
[tool.mypy]
files = ["src", "tests"]
""",
        encoding="utf-8",
    )
    assert decide_mypy_target.decide_use_dot(pyproject) is False

    pyproject.write_text("", encoding="utf-8")
    assert decide_mypy_target.decide_use_dot(pyproject) is True


def test_detect_quality_tools(tmp_path: Path) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text(
        """
[project]
dependencies = ["ruff>=0.1", "mypy==1.0"]

[dependency-groups]
dev = ["pytest", "vulture", "ty"]
""",
        encoding="utf-8",
    )
    tools = detect_quality_tools.detect_tools(pyproject)
    assert tools == {
        "ruff": True,
        "mypy": True,
        "pytest": True,
        "vulture": True,
        "ty": True,
    }


def test_update_readme_version(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    readme = tmp_path / "README.md"
    readme.write_text(
        """
<a href="https://github.com/owner/repo/releases/tag/v0.1.0">Release</a>
<img src="https://img.shields.io/badge/version-v0.1.0-white.svg" />
""",
        encoding="utf-8",
    )
    monkeypatch.setenv("GITHUB_REPOSITORY", "owner/repo")
    monkeypatch.setattr(
        update_readme_version.sys,
        "argv",
        [
            "update_readme_version.py",
            "--readme",
            str(readme),
            "--version",
            "v0.2.0",
        ],
    )

    update_readme_version.main()

    content = readme.read_text(encoding="utf-8")
    assert 'releases/tag/v0.2.0"' in content
    assert "badge/version-v0.2.0-white.svg" in content


def test_update_readme_version_missing_repo(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    readme = tmp_path / "README.md"
    readme.write_text("content", encoding="utf-8")
    monkeypatch.delenv("GITHUB_REPOSITORY", raising=False)
    monkeypatch.setattr(
        update_readme_version.sys,
        "argv",
        ["update_readme_version.py", "--readme", str(readme), "--version", "v0.2.0"],
    )

    with pytest.raises(SystemExit):
        update_readme_version.main()


def test_insert_release_heading_success(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("GITHUB_REPOSITORY", "owner/repo")
    changelog = tmp_path / "CHANGELOG.md"
    changelog.write_text(
        """# CHANGELOG

## Tagged Releases
- [unreleased](https://github.com/owner/repo/compare/v0.1.0...HEAD)
- [0.1.0](https://github.com/owner/repo/compare/v0.0.1...v0.1.0)

## [Unreleased]
""",
        encoding="utf-8",
    )

    update_changelog.insert_release_heading(
        changelog, "0.1.1", "2026-01-05", "## [Unreleased]"
    )

    text = changelog.read_text(encoding="utf-8")
    assert "## [0.1.1] - 2026-01-05" in text
    assert "compare/v0.1.1...HEAD" in text


def test_insert_release_heading_missing_marker(tmp_path: Path) -> None:
    changelog = tmp_path / "CHANGELOG.md"
    changelog.write_text("# CHANGELOG\n", encoding="utf-8")

    with pytest.raises(SystemExit):
        update_changelog.insert_release_heading(
            changelog, "0.1.1", "2026-01-05", "## [Unreleased]"
        )


def test_insert_release_heading_duplicate(tmp_path: Path) -> None:
    changelog = tmp_path / "CHANGELOG.md"
    changelog.write_text(
        """# CHANGELOG

## [Unreleased]

## [0.1.1] - 2026-01-05
""",
        encoding="utf-8",
    )

    with pytest.raises(SystemExit):
        update_changelog.insert_release_heading(
            changelog, "0.1.1", "2026-01-05", "## [Unreleased]"
        )


def test_determine_next_version_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    env_file = tmp_path / "env"
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text('version = "0.1.0"\n', encoding="utf-8")
    monkeypatch.setattr(
        determine_next_version.sys,
        "argv",
        [
            "determine_next_version.py",
            "--pyproject",
            str(pyproject),
            "--bump",
            "minor",
            "--env-file",
            str(env_file),
        ],
    )

    determine_next_version.main()

    content = env_file.read_text(encoding="utf-8")
    assert "CURRENT_VERSION=0.1.0" in content
    assert "RELEASE_VERSION=0.2.0" in content
    assert "RELEASE_TAG=v0.2.0" in content


def test_update_pyproject_version_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text('version = "0.1.0"\n', encoding="utf-8")
    monkeypatch.setattr(
        update_pyproject_version.sys,
        "argv",
        [
            "update_pyproject_version.py",
            "--pyproject",
            str(pyproject),
            "--version",
            "0.2.0",
        ],
    )

    update_pyproject_version.main()

    assert pyproject.read_text(encoding="utf-8").strip() == 'version = "0.2.0"'


def test_decide_mypy_target_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text("", encoding="utf-8")
    output = tmp_path / "out"
    monkeypatch.setenv("GITHUB_OUTPUT", str(output))
    monkeypatch.setattr(
        sys, "argv", ["decide_mypy_target.py", "--pyproject", str(pyproject)]
    )

    decide_mypy_target.main()

    assert output.read_text(encoding="utf-8").strip() == "use_dot=true"


def test_detect_quality_tools_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text(
        """
[dependency-groups]
dev = ["pytest", "ruff", "ty"]
""",
        encoding="utf-8",
    )
    output = tmp_path / "out"
    monkeypatch.setenv("GITHUB_OUTPUT", str(output))
    monkeypatch.setattr(
        sys, "argv", ["detect_quality_tools.py", "--pyproject", str(pyproject)]
    )

    detect_quality_tools.main()

    lines = sorted(output.read_text(encoding="utf-8").splitlines())
    assert "mypy=false" in lines
    assert "pytest=true" in lines
    assert "ruff=true" in lines


def test_update_readme_version_missing_file(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    missing = tmp_path / "README.md"
    monkeypatch.setenv("GITHUB_REPOSITORY", "owner/repo")
    monkeypatch.setattr(
        update_readme_version.sys,
        "argv",
        [
            "update_readme_version.py",
            "--readme",
            str(missing),
            "--version",
            "v0.2.0",
        ],
    )

    with pytest.raises(SystemExit):
        update_readme_version.main()
