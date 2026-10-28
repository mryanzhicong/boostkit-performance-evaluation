"""Verify base OBS paths remain stable while optimized runs are separated."""

import importlib.util
import hashlib
from pathlib import Path
from types import SimpleNamespace

import pytest


SCRIPT = Path(__file__).with_name("obs_transfer.py")
SPEC = importlib.util.spec_from_file_location("obs_transfer", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
obs_transfer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(obs_transfer)


def test_result_and_report_paths_are_separated() -> None:
    common = ("prefix", "Toolchain", "python", "3.14.3", "timestamp_123-1", "aarch64")
    assert obs_transfer.result_key(*common, "base") == (
        "prefix/Toolchain/python/3.14.3/timestamp_123-1/aarch64"
    )
    assert obs_transfer.result_key(*common, "optimized") == (
        "prefix/Toolchain/python/3.14.3/optimized/timestamp_123-1/aarch64"
    )
    assert obs_transfer.report_key("prefix", "timestamp_123-1", "base") == (
        "prefix/reports/timestamp_123-1"
    )
    assert obs_transfer.report_key("prefix", "timestamp_123-1", "optimized") == (
        "prefix/reports/optimized/timestamp_123-1"
    )


def test_unknown_variant_is_rejected() -> None:
    with pytest.raises(RuntimeError, match="invalid build variant"):
        obs_transfer.report_key("prefix", "run", "unknown")


def test_upload_retries_proxy_like_403(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    statuses = iter((403, 403, 200))
    delays = []

    class FakeClient:
        def putFile(self, bucket: str, key: str, path: str) -> SimpleNamespace:
            assert (bucket, key, path) == ("bucket", "key", str(tmp_path / "data"))
            return SimpleNamespace(status=next(statuses), errorCode=None, errorMessage=None)

    monkeypatch.setattr(obs_transfer.time, "sleep", delays.append)
    obs_transfer.put_file(FakeClient(), "bucket", "key", tmp_path / "data")
    assert delays == [2, 4]


def test_upload_does_not_retry_named_obs_403(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    calls = []

    class FakeClient:
        def putFile(self, bucket: str, key: str, path: str) -> SimpleNamespace:
            calls.append(key)
            return SimpleNamespace(status=403, errorCode="AccessDenied", errorMessage="denied")

    monkeypatch.setattr(obs_transfer.time, "sleep", lambda delay: pytest.fail("unexpected retry"))
    with pytest.raises(RuntimeError, match="403 AccessDenied denied"):
        obs_transfer.put_file(FakeClient(), "bucket", "key", tmp_path / "data")
    assert calls == ["key"]


def test_download_retries_proxy_like_403(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    statuses = iter((403, 403, 200))
    delays = []

    class FakeClient:
        def getObject(self, bucket: str, key: str, path: str) -> SimpleNamespace:
            assert (bucket, key, path) == ("bucket", "key", str(tmp_path / "data"))
            return SimpleNamespace(status=next(statuses), errorCode=None, errorMessage=None)

    monkeypatch.setattr(obs_transfer.time, "sleep", delays.append)
    obs_transfer.download_file(FakeClient(), "bucket", "key", tmp_path / "data")
    assert delays == [2, 4]


def test_download_does_not_retry_named_obs_403(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    calls = []

    class FakeClient:
        def getObject(self, bucket: str, key: str, path: str) -> SimpleNamespace:
            calls.append(key)
            return SimpleNamespace(status=403, errorCode="AccessDenied", errorMessage="denied")

    monkeypatch.setattr(obs_transfer.time, "sleep", lambda delay: pytest.fail("unexpected retry"))
    with pytest.raises(RuntimeError, match="403 AccessDenied denied"):
        obs_transfer.download_file(FakeClient(), "bucket", "key", tmp_path / "data")
    assert calls == ["key"]


def test_download_only_selected_manifest_files(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    normalized = b'{"status":"passed"}'
    raw_log = b"large raw log"
    files = [
        {"path": name, "size": len(data), "sha256": hashlib.sha256(data).hexdigest()}
        for name, data in (("normalized_result.json", normalized), ("raw-output.log", raw_log))
    ]
    manifest = {
        "kind": "result", "run_id": "run-1", "result_directory": "directory",
        "variant": "base", "category": "Media", "software": "x265", "version": "4.2",
        "architecture": "aarch64", "files": files,
    }
    downloaded = []

    def fake_download(client, bucket, key, target):
        downloaded.append(key)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(normalized)

    monkeypatch.setattr(obs_transfer, "client", lambda: (object(), "bucket", "prefix"))
    monkeypatch.setattr(obs_transfer, "load_manifest", lambda client, bucket, key: manifest)
    monkeypatch.setattr(obs_transfer, "matrix_entries", lambda path: [{
        "category": "Media", "software": "x265", "version": "4.2", "arch": "aarch64",
    }])
    monkeypatch.setattr(obs_transfer, "download_file", fake_download)
    args = SimpleNamespace(
        destination=str(tmp_path), matrix=str(tmp_path / "matrix.json"), run_id="run-1",
        result_directory="directory", variant="base", only_file=["normalized_result.json"],
    )
    obs_transfer.download_results(args)
    assert downloaded == ["prefix/Media/x265/4.2/directory/aarch64/normalized_result.json"]
