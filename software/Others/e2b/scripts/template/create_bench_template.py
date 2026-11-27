#!/usr/bin/env python3
"""Create (or reuse) the E2B template that sandbox-bench creates sandboxes from.

``sandbox-bench create`` needs a READY template id.  The vendor suite ships none:
``GET /templates`` is empty right after ``build.sh --start``, so this script

1. reads ``SERVER_IP``/``HARBOR_HTTP_PORT`` from ``/opt/e2b-infra/dep/.env``
   (the same file the vendor's deploy.sh writes),
2. tags the pre-loaded ``ubuntu:22.04-custom`` root filesystem into the local
   Harbor project, because the template builder pulls its base image from a
   registry and Docker Hub is unreachable on the runner,
3. asks the template manager to build ``FROM <harbor>/<project>/ubuntu:<tag>``,
4. waits for the template to report ``ready`` and prints the id.

Only an Ubuntu base image works: the vendor's ``provision.sh`` inspects
``/etc/os-release`` inside the sandbox and aborts with ``Unsupported OS`` for a
Debian base image (measured: ``[external] Unsupported OS: debian`` followed by
``error waiting for provisioning sandbox: exit status: 1``).

Usage:
    create_bench_template.py --alias e2b-bench [--base-image ubuntu:22.04-custom]
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

DEFAULT_ENV_FILES = ("/opt/e2b-infra/dep/.env", "/opt/e2b-infra/.env")


def log(message: str) -> None:
    print("[template] %s" % message, flush=True)


def read_env(path: str) -> dict[str, str]:
    """Parse a shell-style env file.

    The vendor ships ``export SERVER_IP=...`` lines, so the ``export`` prefix has
    to be dropped before the key reaches the caller.
    """
    values: dict[str, str] = {}
    try:
        with open(path, encoding="utf-8") as handle:
            for raw in handle:
                line = raw.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, value = line.partition("=")
                key = key.strip()
                if key.startswith("export "):
                    key = key[len("export "):].strip()
                if not key:
                    continue
                values[key] = value.strip().strip('"').strip("'")
    except OSError:
        return {}
    return values


def read_config(path: str) -> dict[str, str]:
    """Read the team key/access token the vendor's deploy.sh wrote."""
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, json.JSONDecodeError):
        return {}
    return data if isinstance(data, dict) else {}


def resolve_harbor(env_files: list[str]) -> tuple[str, int]:
    for path in env_files:
        values = read_env(path)
        server = values.get("SERVER_IP")
        port = values.get("HARBOR_HTTP_PORT", "2900")
        if server:
            return server, int(port)
    raise SystemExit("[template] ERROR: SERVER_IP is missing from %s" % ", ".join(env_files))


def api_request(api_url: str, api_key: str, path: str) -> object:
    request = urllib.request.Request(
        "%s%s" % (api_url.rstrip("/"), path),
        headers={"X-API-Key": api_key},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def list_templates(api_url: str, api_key: str) -> list[dict]:
    try:
        data = api_request(api_url, api_key, "/templates")
    except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError) as exc:
        raise SystemExit("[template] ERROR: GET /templates failed: %s" % exc)
    return data if isinstance(data, list) else []


def find_template(templates: list[dict], alias: str) -> dict | None:
    for item in templates:
        if alias in (item.get("aliases") or []):
            return item
    return None


def docker(*args: str) -> None:
    command = ["sudo", "-n", "docker", *args]
    log(" ".join(command))
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)


def ensure_harbor_base_image(base_image: str, harbor_host: str, project: str) -> str:
    name, _, tag = base_image.partition(":")
    reference = "%s/%s/%s:%s" % (harbor_host, project, name, tag or "latest")
    docker("tag", base_image, reference)
    docker("push", reference)
    return reference


def build_template(api_url: str, api_key: str, alias: str, reference: str,
                   cpu_count: int, memory_mb: int, skip_cache: bool) -> str:
    os.environ.setdefault("E2B_API_URL", api_url)
    os.environ.setdefault("E2B_API_KEY", api_key)
    os.environ.setdefault("E2B_HTTP_SSL", "false")
    os.environ.setdefault("E2B_DOMAIN", "e2b.app")
    try:
        from e2b import Template, default_build_logger
    except ImportError:
        raise SystemExit("[template] ERROR: the e2b SDK is not installed (the suite installer provides it)")
    log("building template %s from %s" % (alias, reference))
    Template.build(
        Template().from_dockerfile("FROM %s" % reference),
        alias=alias,
        cpu_count=cpu_count,
        memory_mb=memory_mb,
        on_build_logs=default_build_logger(),
        skip_cache=skip_cache,
    )
    return alias


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--api-url", default=os.environ.get("E2B_API_URL", "http://127.0.0.1:3000"))
    parser.add_argument("--api-key", default=os.environ.get("E2B_API_KEY", ""))
    parser.add_argument("--config", default="/root/.e2b/config.json")
    parser.add_argument("--alias", default="e2b-bench")
    parser.add_argument("--base-image", default="ubuntu:22.04-custom")
    parser.add_argument("--harbor-host", default="")
    parser.add_argument("--project", default="e2b-orchestration")
    parser.add_argument("--cpu", type=int, default=2)
    parser.add_argument("--memory", type=int, default=2048)
    parser.add_argument("--timeout", type=int, default=900, help="seconds to wait for READY")
    parser.add_argument("--no-skip-cache", action="store_true")
    args = parser.parse_args()

    api_key = args.api_key.strip()
    if not api_key:
        api_key = str(read_config(args.config).get("teamApiKey", "")).strip()
    if not api_key:
        raise SystemExit("[template] ERROR: an API key is required (--api-key or %s)" % args.config)
    if not os.environ.get("E2B_ACCESS_TOKEN"):
        token = str(read_config(args.config).get("accessToken", "")).strip()
        if token:
            os.environ["E2B_ACCESS_TOKEN"] = token

    existing = find_template(list_templates(args.api_url, api_key), args.alias)
    if existing and existing.get("buildStatus") == "ready":
        log("reusing the READY template %s (%s)" % (existing["templateID"], args.alias))
        print("TEMPLATE_ID=%s" % existing["templateID"])
        print("TEMPLATE_ALIAS=%s" % args.alias)
        return 0

    harbor_host = args.harbor_host
    if not harbor_host:
        server, port = resolve_harbor(list(DEFAULT_ENV_FILES))
        harbor_host = "%s:%d" % (server, port)
        log("resolved the local Harbor from the vendor env: %s" % harbor_host)
    reference = ensure_harbor_base_image(args.base_image, harbor_host, args.project)
    build_template(args.api_url, api_key, args.alias, reference,
                   args.cpu, args.memory, not args.no_skip_cache)

    deadline = time.time() + args.timeout
    while time.time() < deadline:
        template = find_template(list_templates(args.api_url, api_key), args.alias)
        if template:
            status = template.get("buildStatus")
            if status == "ready":
                log("template %s is ready" % template["templateID"])
                print("TEMPLATE_ID=%s" % template["templateID"])
                print("TEMPLATE_ALIAS=%s" % args.alias)
                return 0
            if status == "error":
                raise SystemExit("[template] ERROR: the build failed (see GET /templates)")
            log("template %s status=%s, waiting" % (template.get("templateID", "?"), status))
        time.sleep(10)
    raise SystemExit("[template] ERROR: the template did not become ready within %d s" % args.timeout)


if __name__ == "__main__":
    sys.exit(main())
