#!/usr/bin/env python3
"""Write a private Maven settings file, including the workflow proxy if present."""

from __future__ import annotations

import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote, urlsplit


def main() -> int:
    target = Path(sys.argv[1])
    root = ET.Element("settings", xmlns="http://maven.apache.org/SETTINGS/1.0.0")
    proxy_url = os.environ.get("PERF_PROXY", "")
    if proxy_url:
        parsed = urlsplit(proxy_url)
        if parsed.scheme not in {"http", "https"} or not parsed.hostname or not parsed.port:
            raise SystemExit("PERF_PROXY must be an HTTP(S) URL with a host and port")
        proxies = ET.SubElement(root, "proxies")
        for protocol in ("http", "https"):
            proxy = ET.SubElement(proxies, "proxy")
            for key, value in (
                ("id", f"boostkit-{protocol}"),
                ("active", "true"),
                ("protocol", protocol),
                ("host", parsed.hostname),
                ("port", str(parsed.port)),
            ):
                ET.SubElement(proxy, key).text = value
            if parsed.username is not None:
                ET.SubElement(proxy, "username").text = unquote(parsed.username)
            if parsed.password is not None:
                ET.SubElement(proxy, "password").text = unquote(parsed.password)
            ET.SubElement(proxy, "nonProxyHosts").text = "localhost|127.0.0.1"
    target.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(root).write(target, encoding="utf-8", xml_declaration=True)
    target.chmod(0o600)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
