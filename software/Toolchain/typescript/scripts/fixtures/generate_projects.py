#!/usr/bin/env python3
"""Generate the deterministic TypeScript projects of the measurement matrix.

The projects are generated from this script instead of being committed so that
the repository stays small while the inputs are still bit-for-bit reproducible:
the generator is a pure function of the module counts below, and the build stage
refuses to measure unless the generated trees match the hashes published in
``fixtures/projects.json``.

Every project is a self-contained TypeScript workspace with no dependencies at
all (``"types": []``), so a measurement can never touch the network or depend on
the runner's installed packages.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

# The three scales of the type-check matrix.  "small" matches the delivered
# 100-module reference load, "medium" and "large" scale it by 10x and 50x.
TIER_MODULES = {"small": 100, "medium": 1000, "large": 5000}

# Project references build: two composite projects, the application imports the
# library project.
REFERENCE_MODULES = {"lib": 200, "app": 300}

BASE_COMPILER_OPTIONS = {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": True,
    "skipLibCheck": True,
    "types": [],
    "lib": ["ES2022"],
    "exactOptionalPropertyTypes": True,
    "noUncheckedIndexedAccess": True,
    "noImplicitOverride": True,
}

MODULE_TEMPLATE = """\
// deterministic module {index} of the {project} project
{import_line}
export type Brand{index} = string & {{ readonly __brand: {index} }};

export interface Entity{index} {{
  readonly id: Brand{index};
  name: string;
  tags: ReadonlyArray<string>;
  payload: Record<string, number | string | boolean>;
  kind: "alpha" | "beta" | "gamma" | {index};
{previous_field}}}

export type Keys{index} = keyof Entity{index};
export type Picked{index} = Pick<Entity{index}, "id" | "name">;
export type DeepPartial{index}<T> = {{ [K in keyof T]?: DeepPartial{index}<T[K]> }};
export type Result{index}<T> = T extends Entity{index}
  ? {{ ok: true; value: T }}
  : {{ ok: false; error: string }};
export type Conditional{index}<T> = T extends string
  ? `s-${{T}}`
  : T extends number
    ? `n-${{T}}`
    : never;

export const entity{index}: Entity{index} = {{
  id: "id-{index}" as Brand{index},
  name: "entity-{index}",
  tags: ["a", "b"],
  payload: {{ count: {index}, label: "x", enabled: true }},
  kind: {index},
{previous_value}}};

export function pick{index}(value: Entity{index}): Picked{index} {{
  return {{ id: value.id, name: value.name }};
}}

export function isEntity{index}(value: unknown): value is Entity{index} {{
  return typeof value === "object" && value !== null && "id" in value;
}}

export function result{index}(value: Entity{index}): Result{index}<Entity{index}> {{
  return {{ ok: true, value }};
}}

export function describe{index}<T extends string>(value: T): Conditional{index}<T> {{
  return `s-${{value}}` as Conditional{index}<T>;
}}
{link_function}"""

LINK_FUNCTION = """
export function link{index}(previous: Entity{index_minus_one} | null): Entity{index} | null {{
  return previous === null ? null : entity{index};
}}
"""

REFERENCE_MODULE_TEMPLATE = """\
// deterministic module {index} of the {package} project
{import_line}
export interface Model{index} {{
  readonly id: {index};
  label: string;
  values: ReadonlyArray<number | string>;
}}

export type Shape{index} = {{ [K in keyof Model{index}]: Model{index}[K] }};

export const model{index}: Model{index} = {{
  id: {index},
  label: "{package}-{index}",
  values: [{index}, "x", true ? {index} : 0],
}};

export function normalize{index}(value: Model{index}): Shape{index} {{
  return {{ ...value }};
}}
{link_function}"""


def module_source(project: str, index: int) -> str:
    previous_field = f"  previous: Entity{index - 1} | null;\n" if index > 0 else ""
    previous_value = "  previous: null,\n" if index > 0 else ""
    link_function = ""
    if index > 0:
        link_function = LINK_FUNCTION.format(index=index, index_minus_one=index - 1)
    return MODULE_TEMPLATE.format(
        project=project,
        index=index,
        import_line=(
            f'import type {{ Entity{index - 1} }} from "./mod{index - 1:04d}.js";\n'
            if index > 0
            else ""
        ),
        previous_field=previous_field,
        previous_value=previous_value,
        link_function=link_function,
    )


def reference_module_source(package: str, index: int) -> str:
    return REFERENCE_MODULE_TEMPLATE.format(
        package=package,
        index=index,
        import_line=(
            f'import type {{ Model{index - 1} }} from "./mod{index - 1:04d}.js";\n'
            if index > 0
            else ""
        ),
        link_function=(
            f'\nexport function link{index}(previous: Model{index - 1} | null): Model{index} | null {{\n'
            f"  return previous === null ? null : model{index};\n"
            f"}}\n"
            if index > 0
            else ""
        ),
    )


def write_tsconfig(path: Path, options: dict[str, object], include: list[str], extra: dict[str, object] | None = None) -> None:
    payload: dict[str, object] = {"compilerOptions": dict(options), "include": include}
    if extra:
        payload.update(extra)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def generate_check_project(root: Path, project: str, modules: int, emit: bool, incremental: bool) -> None:
    src = root / "src"
    src.mkdir(parents=True, exist_ok=True)
    options = dict(BASE_COMPILER_OPTIONS)
    options["noEmit"] = not emit
    if emit:
        options.update(
            {
                "outDir": "./dist",
                "rootDir": "./src",
                "declaration": True,
                "declarationMap": True,
                "sourceMap": True,
            }
        )
    if incremental:
        options["incremental"] = True
        options["tsBuildInfoFile"] = "./.tsbuildinfo"
    write_tsconfig(root / "tsconfig.json", options, ["src/**/*.ts"])
    for index in range(modules):
        (src / f"mod{index:04d}.ts").write_text(module_source(project, index), encoding="utf-8")


def generate_references_project(root: Path) -> None:
    (root / "packages" / "lib" / "src").mkdir(parents=True, exist_ok=True)
    (root / "packages" / "app" / "src").mkdir(parents=True, exist_ok=True)
    (root / "package.json").write_text(
        json.dumps({"name": "typescript-references", "private": True}, indent=2) + "\n",
        encoding="utf-8",
    )
    (root / "tsconfig.json").write_text(
        json.dumps(
            {
                "files": [],
                "references": [{"path": "./packages/lib"}, {"path": "./packages/app"}],
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    library_options = dict(BASE_COMPILER_OPTIONS)
    library_options.update(
        {
            "composite": True,
            "declaration": True,
            "declarationMap": True,
            "rootDir": "./src",
            "outDir": "./dist",
        }
    )
    write_tsconfig(root / "packages" / "lib" / "tsconfig.json", library_options, ["src/**/*.ts"])
    application_options = dict(BASE_COMPILER_OPTIONS)
    application_options.update({"composite": True, "noEmit": True})
    write_tsconfig(
        root / "packages" / "app" / "tsconfig.json",
        application_options,
        ["src/**/*.ts"],
        {"references": [{"path": "../lib"}]},
    )
    for index in range(REFERENCE_MODULES["lib"]):
        (root / "packages" / "lib" / "src" / f"mod{index:04d}.ts").write_text(
            reference_module_source("lib", index), encoding="utf-8"
        )
    library_modules = REFERENCE_MODULES["lib"]
    for index in range(REFERENCE_MODULES["app"]):
        library_index = index % library_modules
        (root / "packages" / "app" / "src" / f"mod{index:04d}.ts").write_text(
            f"// deterministic module {index} of the app project\n"
            f'import type {{ Model{library_index} }} from "../../lib/src/mod{library_index:04d}.js";\n'
            f"\n"
            f"export type AppShape{index} = Model{library_index} & {{ readonly appId: {index} }};\n"
            f"\n"
            f"export const app{index}: AppShape{index} = {{\n"
            f"  id: {library_index},\n"
            f'  label: "app-{index}",\n'
            f"  values: [{index}, {library_index}],\n"
            f"  appId: {index},\n"
            f"}};\n",
            encoding="utf-8",
        )


def tree_digest(root: Path) -> str:
    """Deterministic digest of a project tree (path + content of every file)."""
    digest = hashlib.sha256()
    for path in sorted(entry for entry in root.rglob("*") if entry.is_file()):
        relative = path.relative_to(root).as_posix()
        file_digest = hashlib.sha256(path.read_bytes()).hexdigest()
        digest.update(f"{relative}\0{file_digest}\n".encode())
    return digest.hexdigest()


def project_layout() -> dict[str, dict[str, object]]:
    return {
        "small": {"kind": "check", "modules": TIER_MODULES["small"]},
        "medium": {"kind": "check", "modules": TIER_MODULES["medium"]},
        "large": {"kind": "check", "modules": TIER_MODULES["large"]},
        "emit": {"kind": "emit", "modules": TIER_MODULES["medium"]},
        "incremental": {"kind": "incremental", "modules": TIER_MODULES["medium"]},
        "references": {"kind": "references", "packages": dict(REFERENCE_MODULES)},
    }


def generate_all(output: Path) -> dict[str, object]:
    layout = project_layout()
    summary: dict[str, object] = {}
    for name, entry in layout.items():
        root = output / name
        if root.exists():
            for path in sorted(root.rglob("*"), reverse=True):
                if path.is_file():
                    path.unlink()
                elif path.is_dir():
                    path.rmdir()
            root.rmdir()
        root.mkdir(parents=True)
        kind = str(entry["kind"])
        modules = int(entry.get("modules", 0))
        if kind == "check":
            generate_check_project(root, name, modules, emit=False, incremental=False)
        elif kind == "emit":
            generate_check_project(root, name, modules, emit=True, incremental=False)
        elif kind == "incremental":
            generate_check_project(root, name, modules, emit=False, incremental=True)
        else:
            generate_references_project(root)
        summary[name] = {
            "digest": tree_digest(root),
            "modules": modules,
            **({"packages": entry["packages"]} if "packages" in entry else {}),
        }
    return summary


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="directory that receives the projects")
    parser.add_argument(
        "--summary",
        type=Path,
        default=None,
        help="write the project digests as JSON to this path",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    summary = generate_all(args.output)
    payload = {"generator": "scripts/fixtures/generate_projects.py", "projects": summary}
    text = json.dumps(payload, indent=2, sort_keys=True) + "\n"
    if args.summary is not None:
        args.summary.write_text(text, encoding="utf-8")
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
