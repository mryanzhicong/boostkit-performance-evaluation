"""The template helper parses the vendor's env file, which uses `export`."""

from __future__ import annotations

import importlib.util
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
TEMPLATE = CASE / "scripts" / "template" / "create_bench_template.py"


def load_module():
    spec = importlib.util.spec_from_file_location("create_bench_template", TEMPLATE)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_read_env_accepts_export_prefix(tmp_path: Path) -> None:
    env = tmp_path / ".env"
    env.write_text(
        "# comment\n"
        "export SERVER_IP=192.168.20.14\n"
        'export SERVER_IPS="$SERVER_IP"\n'
        "export HARBOR_HTTP_PORT=2900\n"
        "PLAIN_KEY=plain\n",
        encoding="utf-8",
    )
    values = load_module().read_env(str(env))
    assert values["SERVER_IP"] == "192.168.20.14"
    assert values["SERVER_IPS"] == "$SERVER_IP"
    assert values["HARBOR_HTTP_PORT"] == "2900"
    assert values["PLAIN_KEY"] == "plain"
    assert "export SERVER_IP" not in values


def test_resolve_harbor_uses_the_exported_value(tmp_path: Path) -> None:
    env = tmp_path / ".env"
    env.write_text("export SERVER_IP=10.1.2.3\nexport HARBOR_HTTP_PORT=3900\n", encoding="utf-8")
    module = load_module()
    assert module.resolve_harbor([str(env)]) == ("10.1.2.3", 3900)


def test_resolve_harbor_defaults_the_port(tmp_path: Path) -> None:
    env = tmp_path / ".env"
    env.write_text("export SERVER_IP=10.1.2.3\n", encoding="utf-8")
    module = load_module()
    assert module.resolve_harbor([str(env)]) == ("10.1.2.3", 2900)
