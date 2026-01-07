"""Generate static API documentation"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from fastapi.openapi.docs import get_redoc_html
from src.main import app as fastapi_app

if TYPE_CHECKING:
    from fastapi import FastAPI

ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))


def _output_dir() -> Path:
    """Resolve output directory from env with a sane default and safety checks."""
    env_dir = os.environ.get("API_DOCS_OUTPUT_DIR")
    base_dir = ROOT_DIR.resolve()
    if env_dir:
        candidate = Path(env_dir)
        if not candidate.is_absolute():
            candidate = base_dir / candidate
    else:
        candidate = base_dir / "docs" / "api-docs"
    resolved = candidate.resolve()
    try:
        within_repo = resolved.is_relative_to(base_dir)
    except AttributeError:  # Python <3.9 fallback (not expected here)
        within_repo = str(resolved).startswith(str(base_dir))
    if not within_repo:
        message = f"OUTPUT_DIR must reside under the repository. Got: {resolved}"
        raise ValueError(message)
    return resolved


OUTPUT_DIR = _output_dir()


def write_openapi_json(fastapi_app: FastAPI) -> Path:
    """Render the OpenAPI schema to a JSON file."""
    schema = fastapi_app.openapi()
    output_path = OUTPUT_DIR / "openapi.json"
    output_path.write_text(json.dumps(schema, indent=2) + "\n", encoding="utf-8")
    return output_path


def write_redoc_html(fastapi_app: FastAPI, openapi_url: str = "openapi.json") -> Path:
    """Render a Redoc HTML page that references the generated schema."""
    html_response = get_redoc_html(
        openapi_url=openapi_url,
        title=f"{fastapi_app.title or 'API'} Documentation",
        with_google_fonts=False,
    )
    html_body = html_response.body
    if isinstance(html_body, (bytes, bytearray)):
        html_content = html_body.decode("utf-8")
    else:
        html_content = str(html_body)
    output_path = OUTPUT_DIR / "index.html"
    output_path.write_text(html_content, encoding="utf-8")
    return output_path


def main() -> None:
    """Generate API documentation assets."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    json_path = write_openapi_json(fastapi_app)
    html_path = write_redoc_html(fastapi_app)
    print(f"Wrote {json_path.relative_to(Path.cwd())}")
    print(f"Wrote {html_path.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
