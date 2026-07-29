from __future__ import annotations

import argparse
import os
import pathlib
import re
import shutil
import sys
from subprocess import (  # ruff:ignore[suspicious-subprocess-import]
    CalledProcessError,
    check_output,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="CHANGELOG.md の Unreleased セクション"
        "直後に新しいリリース見出しを挿入します。"
    )
    parser.add_argument(
        "--changelog", default="CHANGELOG.md", help="更新する CHANGELOG.md"
    )
    parser.add_argument(
        "--version", required=True, help="リリースバージョン (例: 0.2.0)"
    )
    parser.add_argument("--date", required=True, help="リリース日 (YYYY-MM-DD)")
    parser.add_argument(
        "--marker", default="## [Unreleased]", help="挿入位置となるマーカー文字列"
    )
    return parser.parse_args()


def insert_release_heading(
    path: pathlib.Path, version: str, date: str, marker: str
) -> None:
    if not path.exists():
        print(f"{path} が見つかりません。", file=sys.stderr)
        raise SystemExit(1)

    text = path.read_text(encoding="utf-8")
    text = _update_tagged_releases(text, version)
    heading = f"## [{version}] - {date}"

    if heading in text:
        print(f"{heading} は既に存在します。", file=sys.stderr)
        raise SystemExit(1)

    try:
        idx = text.index(marker) + len(marker)
    except ValueError:
        print(f"{path} に '{marker}' セクションが見つかりません。", file=sys.stderr)
        raise SystemExit(1) from ValueError

    insertion = f"\n\n{heading}\n\n"
    updated = _normalize_blank_lines(text[:idx] + insertion + text[idx:])
    path.write_text(updated, encoding="utf-8")


def _normalize_blank_lines(text: str) -> str:
    """2 行以上の空行を 1 行にまとめる。

    Returns:
        str: 空行が正規化された文字列。
    """
    lines: list[str] = []
    blank = False
    for line in text.splitlines(keepends=True):
        if not line.strip():
            if not blank:
                lines.append(line)
            blank = True
        else:
            lines.append(line)
            blank = False
    return "".join(lines)


def _infer_base_url_from_text(text: str) -> str | None:
    """CHANGELOG から GitHub リポジトリのベース URL を推測する。

    Returns:
        ベース URL を表す文字列。推測できなければ None。
    """
    match = re.search(r"https?://github\.com/[^/\s)]+/[^/\s)]+", text)
    if match:
        return match.group(0).rstrip("/")
    return None


def _infer_base_url_from_env() -> str | None:
    """環境変数や git 設定から GitHub ベース URL を推測する。

    Returns:
        ベース URL を表す文字列。推測できなければ None。
    """
    repo = os.environ.get("GITHUB_REPOSITORY")
    if repo:
        return f"https://github.com/{repo}".rstrip("/")

    git_path = shutil.which("git")
    if not git_path:
        return None

    try:
        remote = check_output(  # ruff:ignore[subprocess-without-shell-equals-true]
            [git_path, "config", "--get", "remote.origin.url"], text=True
        ).strip()
    except (CalledProcessError, FileNotFoundError):
        remote = ""

    if not remote:
        return None

    # git@github.com:owner/repo(.git)?
    ssh_match = re.match(
        r"git@[^:]+:(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$", remote
    )
    if ssh_match:
        return (
            f"https://github.com/{ssh_match.group('owner')}/{ssh_match.group('repo')}"
        )

    # https://github.com/owner/repo(.git)?
    https_match = re.match(
        r"https?://[^/]+/(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$", remote
    )
    if https_match:
        return f"https://github.com/{https_match.group('owner')}/{https_match.group('repo')}"

    return None


def _render_tagged_body(entries: list[tuple[str, str]]) -> str:
    lines = [f"- [{label}]({url})\n" for label, url in entries]
    body = "\n" + "".join(lines)
    if not body.endswith("\n"):
        body += "\n"
    if not body.endswith("\n\n"):
        body += "\n"
    return body


def _update_tagged_releases(text: str, version: str) -> str:  # ruff:ignore[too-many-return-statements, too-many-branches, complex-structure]
    """`## Tagged Releases` の差分リンクを最新タグにあわせて更新する。

    期待するフォーマット:

    - [unreleased](https://github.com/org/repo/compare/v0.1.8...HEAD)
    - [0.1.8](https://github.com/org/repo/compare/v0.1.7...v0.1.8)
    - ...

    Args:
        text: CHANGELOG 全文。
        version: 新しいリリースバージョン (例: "0.2.0").

    Returns:
        差分リンクを更新したテキスト。該当セクションが無い場合はそのまま返す。
    """
    section_re = re.compile(r"(?ms)^## Tagged Releases\s*\n(?P<body>.*?)(?=^## |\Z)")
    match = section_re.search(text)
    if not match:
        return text

    body = match.group("body")
    entries: list[tuple[str, str]] = []
    entry_re = re.compile(r"^- \[([^\]]+)]\(([^)]+)\)")
    for line in body.splitlines():
        m = entry_re.match(line.strip())
        if m:
            entries.append((m.group(1), m.group(2)))

    if len(entries) == 0:
        base_url = _infer_base_url_from_env() or _infer_base_url_from_text(text)
        if not base_url:
            return text

        prefix = "v"
        new_entries = [
            ("unreleased", f"{base_url}/compare/{prefix}{version}...HEAD"),
            (version, f"{base_url}/releases/tag/{prefix}{version}"),
        ]
        new_body = _render_tagged_body(new_entries)
        return text[: match.start("body")] + new_body + text[match.end("body") :]

    # 未リリース + 1件の既存リリースが必要
    if len(entries) < 2:  # ruff:ignore[magic-value-comparison]
        return text

    base_url = None
    for _, url in entries:
        for marker in ("/compare/", "/releases/tag/"):
            idx = url.find(marker)
            if idx != -1:
                base_url = url[:idx]
                break
        if base_url:
            break

    if not base_url:
        return text

    prefix = "v"
    for _, url in entries:
        comp = re.search(r"/compare/([^/]+?)\.\.\.([^/)]+)", url)
        if comp:
            for tag in comp.groups():
                if tag.upper() == "HEAD" or not any(ch.isdigit() for ch in tag):
                    continue
                tag_match = re.match(r"(?P<prefix>[^0-9]*)(?P<ver>.+)", tag)
                if tag_match:
                    prefix = tag_match.group("prefix")
                    break
            if prefix != "v":  # 推定できた場合のみ抜ける
                break

    try:
        previous_version = next(
            label for label, _ in entries if label.lower() != "unreleased"
        )
    except StopIteration:
        return text

    new_entries = [
        ("unreleased", f"{base_url}/compare/{prefix}{version}...HEAD"),
        (version, f"{base_url}/compare/{prefix}{previous_version}...{prefix}{version}"),
    ]
    new_entries.extend(
        (label, url) for label, url in entries if label.lower() != "unreleased"
    )

    new_body = _render_tagged_body(new_entries)
    return text[: match.start("body")] + new_body + text[match.end("body") :]


def main() -> None:
    args = parse_args()
    insert_release_heading(
        pathlib.Path(args.changelog), args.version, args.date, args.marker
    )
    print(f"CHANGELOG に {args.version} ({args.date}) を追加しました。")


if __name__ == "__main__":
    main()
