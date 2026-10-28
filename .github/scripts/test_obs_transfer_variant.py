"""Verify base OBS paths remain stable while optimized runs are separated."""

import importlib.util
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
