#!/usr/bin/env python3
"""Generate the deterministic Next.js application matrix for the performance case.

The matrix is generated instead of committed because 1000+ page files would bloat
the repository, and because a generator makes the workload reproducible: the
committed fixtures/projects.json records the SHA-256 tree digest of every project,
so a change in the generated input is detected by the build stage.

Projects:
  static_1000   one dynamic route with generateStaticParams(1000); the delivery
                load (fixed 1000 static pages, production build)
  static_3000   the same shape with 3000 static pages (scale sensitivity)
  dynamic_500   a server-rendered route (force-dynamic) with 500 possible ids
                (request-time rendering instead of static generation)
  routes_500    500 separate file-system routes, each a static page (route
                table / compilation scaling, not static generation scaling)
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from pathlib import Path

GENERATOR_NAME = "nextjs-project-matrix"
GENERATOR_VERSION = 1

NEXT_CONFIG = """\
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Pin the static generation parallelism so the same workload is comparable on
  // runners with a different CPU count. Recorded as a workload parameter.
  experimental: {
    cpus: 2,
  },
  poweredByHeader: false,
  // The dependency tree is shared by all projects and lives above the app
  // directory, so Turbopack needs the work directory as its workspace root.
  // NEXT_TURBOPACK_ROOT is set by the stages; it is a location, not a workload
  // parameter, so it never enters the parameter signature.
  turbopack: {
    root: process.env.NEXT_TURBOPACK_ROOT || __dirname,
  },
};

module.exports = nextConfig;
"""

LAYOUT = """\
export const metadata = {
  title: 'nextjs performance fixture',
  description: 'deterministic pages for the nextjs performance case',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
"""

HOME_PAGE = """\
import Link from 'next/link';

export default function HomePage() {
  return (
    <main>
      <h1>fixture</h1>
      <p>
        <Link href="/items/item-0">first item</Link>
      </p>
    </main>
  );
}
"""

STATIC_ITEMS_PAGE = """\
export const dynamicParams = false;

export function generateStaticParams() {
  return Array.from({ length: ITEMS }, (_, index) => ({ id: `item-${index}` }));
}

export default async function ItemPage({ params }) {
  const { id } = await params;
  return (
    <main>
      <h1>{id}</h1>
      <p data-testid="item-id">{id}</p>
    </main>
  );
}
"""

DYNAMIC_PAGE = """\
export const dynamic = 'force-dynamic';

export default async function DynamicPage({ params }) {
  const { id } = await params;
  return (
    <main>
      <h1>{id}</h1>
      <p data-testid="dynamic-id">{id}</p>
    </main>
  );
}
"""

FILE_ROUTE_PAGE = """\
export default function FileRoutePage() {
  return (
    <main>
      <h1>route-ROUTE</h1>
      <p data-testid="route-id">route-ROUTE</p>
    </main>
  );
}
"""


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def package_json(name: str) -> str:
    return json.dumps(
        {"name": name, "version": "1.0.0", "private": True},
        indent=2,
    ) + "\n"


def build_static(root: Path, name: str, items: int) -> None:
    write(root / "package.json", package_json(name))
    write(root / "next.config.js", NEXT_CONFIG)
    write(root / "app" / "layout.js", LAYOUT)
    write(root / "app" / "page.js", HOME_PAGE)
    write(root / "app" / "items" / "[id]" / "page.js", STATIC_ITEMS_PAGE.replace("ITEMS", str(items)))


def build_dynamic(root: Path, name: str, route_count: int) -> None:
    write(root / "package.json", package_json(name))
    write(root / "next.config.js", NEXT_CONFIG)
    write(root / "app" / "layout.js", LAYOUT)
    write(root / "app" / "page.js", HOME_PAGE)
    write(root / "app" / "dyn" / "[id]" / "page.js", DYNAMIC_PAGE)
    # route_count documents the number of ids the route is exercised with; the
    # route itself is a single dynamic segment, so no files are added.
    write(root / "route-catalog.json", json.dumps({"routes": route_count}, indent=2) + "\n")


def build_file_routes(root: Path, name: str, routes: int) -> None:
    write(root / "package.json", package_json(name))
    write(root / "next.config.js", NEXT_CONFIG)
    write(root / "app" / "layout.js", LAYOUT)
    write(root / "app" / "page.js", HOME_PAGE)
    for index in range(routes):
        route = f"route-{index:04d}"
        write(
            root / "app" / "files" / route / "page.js",
            FILE_ROUTE_PAGE.replace("ROUTE", route),
        )


def tree_digest(root: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(hashlib.sha256(path.read_bytes()).hexdigest().encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def source_file_count(root: Path) -> int:
    suffixes = {".js", ".jsx", ".ts", ".tsx", ".mjs", ".json"}
    return sum(
        1
        for path in root.rglob("*")
        if path.is_file()
        and path.suffix in suffixes
        and "node_modules" not in path.parts
        and ".next" not in path.parts
    )


def generate(output: Path) -> dict:
    projects: dict[str, dict] = {}
    specs = (
        ("static_1000", lambda root: build_static(root, "static_1000", 1000), 1000 + 5),
        ("static_3000", lambda root: build_static(root, "static_3000", 3000), 3000 + 5),
        ("dynamic_500", lambda root: build_dynamic(root, "dynamic_500", 500), 5),
        ("routes_500", lambda root: build_file_routes(root, "routes_500", 500), 500 + 5),
    )
    for name, builder, expected_html in specs:
        root = output / name
        if root.exists():
            shutil.rmtree(root)
        builder(root)
        projects[name] = {
            "digest": tree_digest(root),
            "source_files": source_file_count(root),
            "expected_html_pages": expected_html,
        }
    return {
        "generator": GENERATOR_NAME,
        "generator_version": GENERATOR_VERSION,
        "projects": projects,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--summary", type=Path)
    arguments = parser.parse_args()
    arguments.output.mkdir(parents=True, exist_ok=True)
    summary = generate(arguments.output)
    if arguments.summary:
        arguments.summary.parent.mkdir(parents=True, exist_ok=True)
        arguments.summary.write_text(
            json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
    for name, entry in sorted(summary["projects"].items()):
        print(
            f"[nextjs-fixtures] {name:<12} source_files={entry['source_files']:<4} "
            f"html={entry['expected_html_pages']:<5} digest={entry['digest'][:16]}…",
            flush=True,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
