#!/usr/bin/env python3
"""TPC-DS metadata helpers shared by the loader and the query driver.

The schema comes from the pinned hive-testbench text DDL that the document's
workload uses.  Only its column list is reused: the single-node case keeps flat
ORC tables instead of the document's Hive partitioned tables because a private
container has no Hive metastore.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from pathlib import Path

CREATE_RE = re.compile(
    r"create\s+(?:external\s+)?table\s+(?:if\s+not\s+exists\s+)?([a-z_][a-z0-9_]*)",
    re.IGNORECASE,
)
COLUMN_RE = re.compile(r"^\s*([a-z_][a-z0-9_]*)\s+([a-z]+(?:\s*\(\s*\d+\s*(?:,\s*\d+\s*)?\))?)\s*$", re.IGNORECASE)
LOCATION_RE = re.compile(r"location\s+'([^']+)'", re.IGNORECASE)

# Hive type -> Spark SQL type.  Dates and times are stored as strings in the
# pinned DDL, so nothing is silently coerced into a different calendar type.
TYPE_MAP = {
    "int": "int",
    "integer": "int",
    "bigint": "bigint",
    "smallint": "smallint",
    "tinyint": "tinyint",
    "float": "float",
    "double": "double",
    "string": "string",
    "boolean": "boolean",
    "date": "date",
    "timestamp": "timestamp",
}


@dataclass(frozen=True)
class Table:
    name: str
    columns: tuple[tuple[str, str], ...]
    location: str | None

    @property
    def spark_columns(self) -> list[tuple[str, str]]:
        return [(name, spark_type(hive_type)) for name, hive_type in self.columns]


def spark_type(hive_type: str) -> str:
    lowered = hive_type.strip().lower().replace(" ", "")
    if lowered.startswith(("char(", "varchar(")):
        return "string"
    if lowered.startswith("decimal("):
        return lowered
    if lowered in TYPE_MAP:
        return TYPE_MAP[lowered]
    raise ValueError(f"unsupported column type in the pinned TPC-DS DDL: {hive_type}")


def split_statement(text: str, start: int) -> tuple[str, str]:
    """Return the parenthesised column list and the trailing clause of one DDL statement.

    A plain regular expression cannot be used here: the column types contain their
    own parentheses (``varchar(16)``, ``decimal(7,2)``), so the column list is found
    by scanning and the trailing clause ends at the statement's semicolon.
    """
    open_at = text.index("(", start)
    depth = 0
    for index in range(open_at, len(text)):
        character = text[index]
        if character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                end = text.find(";", index)
                if end < 0:
                    raise ValueError("unterminated DDL statement in the pinned DDL")
                return text[open_at + 1 : index], text[index + 1 : end]
    raise ValueError("unbalanced parentheses in the pinned DDL")


def parse_ddl(text: str) -> list[Table]:
    tables: list[Table] = []
    for match in CREATE_RE.finditer(text):
        name = match.group(1).lower()
        body, tail = split_statement(text, match.end())
        columns: list[tuple[str, str]] = []
        for raw in body.splitlines():
            # The pinned Hive DDL puts the leading comma of every column except the
            # first at the start of the next line, so both sides are trimmed.
            line = raw.split("--", 1)[0].strip().strip(",").strip()
            if not line:
                continue
            column = COLUMN_RE.match(line)
            if not column:
                continue
            columns.append((column.group(1).lower(), column.group(2).strip()))
        if not columns:
            raise ValueError(f"table {name} has no parsable columns in the pinned DDL")
        location_match = LOCATION_RE.search(tail or "")
        tables.append(Table(name=name, columns=tuple(columns), location=location_match.group(1) if location_match else None))
    if not tables:
        raise ValueError("no TPC-DS table definition found in the pinned DDL")
    names = [table.name for table in tables]
    if len(set(names)) != len(names):
        raise ValueError("duplicate table definition in the pinned DDL")
    return tables


def load_tables(ddl_path: Path) -> list[Table]:
    return parse_ddl(ddl_path.read_text(encoding="utf-8"))


# Two Hive/Impala spellings of interval arithmetic are not valid Spark SQL:
# ``+ 14 days`` and ``INTERVAL(5) DAY``.  Both are rewritten to ``interval N unit``.
# The manifest digests cover the rewritten text, so changing a rule changes the
# pinned workload; the rewrite is deterministic and never touches table or column
# names, predicates or the statement order.
INTERVAL_SUFFIX_RE = re.compile(
    r"([+-])\s+(\d+)\s+(day|days|month|months|year|years)\b", re.IGNORECASE
)
INTERVAL_CALL_RE = re.compile(
    r"\binterval\s*\(\s*(\d+)\s*\)\s*"
    r"(day|days|month|months|year|years|hour|hours|minute|minutes|second|seconds)\b",
    re.IGNORECASE,
)


def normalize_statement(sql: str) -> str:
    sql = INTERVAL_CALL_RE.sub(lambda match: f"interval {match.group(1)} {match.group(2)}", sql)
    return INTERVAL_SUFFIX_RE.sub(
        lambda match: f"{match.group(1)} interval {match.group(2)} {match.group(3)}", sql
    )


def statement_text(path: Path) -> str:
    """Return the single statement Spark executes for a pinned query file.

    hive-testbench ships Q14/Q23/Q24/Q39 as two equivalent rewrites separated by a
    semicolon; only the first rewrite is measured, so every sample executes exactly
    one statement per file.
    """
    sql = path.read_text(encoding="utf-8").split(";")[0].strip()
    if not sql:
        raise ValueError(f"empty TPC-DS statement: {path}")
    return normalize_statement(sql) + "\n"


def statement_files(query_dir: Path) -> list[Path]:
    """Return the pinned TPC-DS statements ordered by their numeric id."""
    numbered = []
    for path in query_dir.glob("query*.sql"):
        match = re.fullmatch(r"query(\d+)\.sql", path.name)
        if match:
            numbered.append((int(match.group(1)), path))
    if not numbered:
        raise ValueError(f"no query statements found in {query_dir}")
    numbered.sort()
    ids = [number for number, _ in numbered]
    if ids != list(range(1, len(ids) + 1)):
        raise ValueError("the pinned TPC-DS statement set is not contiguous from query1.sql")
    return [path for _, path in numbered]


def file_digest(path: Path) -> str:
    """Digest of the normalised statement text, i.e. exactly what Spark executes."""
    return hashlib.sha256(statement_text(path).encode("utf-8")).hexdigest()


def manifest(tables: list[Table], query_dir: Path, query_count: int) -> dict:
    statements = statement_files(query_dir)[:query_count]
    return {
        "tables": [
            {"name": table.name, "columns": [name for name, _ in table.columns]}
            for table in tables
        ],
        "statements": [{"name": path.name, "sha256": file_digest(path)} for path in statements],
    }
