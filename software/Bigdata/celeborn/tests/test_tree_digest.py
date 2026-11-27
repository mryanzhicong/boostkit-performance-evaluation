from __future__ import annotations

import importlib.util
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "tree_digest", CASE_DIR / "scripts" / "builders" / "tree_digest.py"
)
assert SPEC and SPEC.loader
tree_digest = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(tree_digest)


def make_tree(root: Path) -> Path:
    (root / "tools").mkdir(parents=True)
    (root / "tools" / "dsdgen.c").write_text("int main(void) { return 0; }\n", encoding="utf-8")
    (root / "README").write_text("tpcds-kit\n", encoding="utf-8")
    return root


def test_digest_is_stable_and_content_addressed(tmp_path: Path) -> None:
    first = tree_digest.tree_digest(make_tree(tmp_path / "a"))
    second = tree_digest.tree_digest(make_tree(tmp_path / "b"))
    assert first == second
    assert len(first) == 64

    changed = make_tree(tmp_path / "c")
    (changed / "README").write_text("tpcds-kit patched\n", encoding="utf-8")
    assert tree_digest.tree_digest(changed) != first


def test_expected_digest_gate(tmp_path: Path, capsys) -> None:
    root = make_tree(tmp_path / "d")
    digest = tree_digest.tree_digest(root)
    assert tree_digest.main([str(root), "--expected", digest]) == 0
    assert tree_digest.main([str(root), "--expected", "0" * 64]) == 30
    assert "tree digest mismatch" in capsys.readouterr().err


def test_empty_tree_is_rejected(tmp_path: Path) -> None:
    empty = tmp_path / "empty"
    empty.mkdir()
    try:
        tree_digest.tree_digest(empty)
    except SystemExit as error:
        assert "contains no files" in str(error)
    else:  # pragma: no cover - the digest must never accept an empty tree
        raise AssertionError("an empty tree must not produce a digest")
