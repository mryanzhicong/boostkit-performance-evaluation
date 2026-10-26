"""Keep the original shell scripts unchanged and validate the result adapter."""

from __future__ import annotations

import importlib.util
from decimal import Decimal
from pathlib import Path

import pytest


MEDIA_DIR = Path(__file__).resolve().parents[1]
MODULE_PATH = MEDIA_DIR / "collect_reference.py"
SPEC = importlib.util.spec_from_file_location("collect_reference", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
reference = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(reference)

ORIGINAL_SHA256 = {
    "x264/scripts/fps-encode-x264.sh": "1f041acad96c7911fa2c3eeacaa983a8bb2ac5fe18df0e0d137d361126eba461",
    "x264/scripts/score-x264.sh": "6255a5cc16ef58ed58f3529ae67e77462ac48ff956e9fc1159aff1abbad06793",
    "x265/scripts/fps-encode-x265.sh": "2ba13537fcca2b9dd1665eca1ce63fc5947cd9c1aea64d5f1fb0278f61732db9",
    "x265/scripts/score-x265.sh": "96205cb6e540e09886e92d34b3688ccf0feecae05ca846ca4e8a21427e03294e",
}


def test_reference_scripts_remain_byte_for_byte_original() -> None:
    for relative_path, expected in ORIGINAL_SHA256.items():
        assert reference.sha256_file(MEDIA_DIR / relative_path) == expected


@pytest.mark.parametrize(
    ("encoder", "log_line"),
    [
        ("x264", "encoded 1 frames, 12.50 fps, 2000.00 kb/s"),
        ("x265", "encoded 1 frames in 0.08s (12.50 fps), 2000.00 kb/s"),
    ],
)
def test_collects_original_script_csv_and_route_output(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, encoder: str, log_line: str
) -> None:
    monkeypatch.setattr(reference, "VIDEO_NAMES", ("sample",))
    monkeypatch.setattr(reference, "BITRATES", (2000,))
    monkeypatch.setattr(reference, "FRAME_BYTES", 6)
    video_dir = tmp_path / "video"
    video_dir.mkdir()
    (video_dir / "sample.yuv").write_bytes(b"123456")
    videos = reference.inspect_videos(video_dir)
    route_dir = tmp_path / f"outputfiles-{encoder}" / "2000k" / "sample"
    route_dir.mkdir(parents=True)
    (route_dir / "log_sample_2000k_1.txt").write_text(log_line + "\n", encoding="utf-8")
    (route_dir / "sample_2000k_1.bin").write_bytes(b"1234")
    csv_path = tmp_path / "score.csv"
    csv_path.write_text(
        "Bitrate,Video Directory,Total FPS,Average Bin Size\n"
        "2000k,sample,12.50,4\n",
        encoding="utf-8",
    )
    rows = reference.read_summary(csv_path)
    assert rows[("sample", 2000)] == (Decimal("12.50"), Decimal(4))
    raw_output = tmp_path / "raw.log"
    raw_output.write_text("original command output\n", encoding="utf-8")
    results = reference.collect(encoder, tmp_path, raw_output, rows, videos)
    assert results["sample/2000k/total_fps"]["value"] == 12.5
    assert results["sample/2000k/total_fps"]["group"] == "2000 kb/s"
    assert log_line in raw_output.read_text(encoding="utf-8")


def test_rejects_incomplete_original_output(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(reference, "VIDEO_NAMES", ("sample",))
    monkeypatch.setattr(reference, "BITRATES", (2000,))
    with pytest.raises(ValueError, match="missing"):
        reference.read_summary(tmp_path / "missing.csv")


def test_x264_accepts_three_known_videos_without_weakening_result_checks(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(reference, "VIDEO_NAMES", ("one", "two", "three", "four"))
    monkeypatch.setattr(reference, "BITRATES", (2000, 4000))
    monkeypatch.setattr(reference, "FRAME_BYTES", 6)
    video_dir = tmp_path / "video"
    video_dir.mkdir()
    for name in ("one", "two", "three"):
        (video_dir / f"{name}.yuv").write_bytes(b"123456")

    with pytest.raises(ValueError, match="reference video set differs"):
        reference.inspect_videos(video_dir)
    videos = reference.inspect_videos(video_dir, allow_subset=True)
    assert set(videos) == {"one", "two", "three"}

    csv_path = tmp_path / "score.csv"
    header = "Bitrate,Video Directory,Total FPS,Average Bin Size\n"
    rows = "".join(
        f"{bitrate}k,{name},12.50,4\n"
        for name in videos
        for bitrate in (2000, 4000)
    )
    csv_path.write_text(header + rows, encoding="utf-8")
    selected_rows = reference.read_summary(csv_path, set(videos))
    assert len(selected_rows) == 6

    for name, bitrate in selected_rows:
        route_dir = tmp_path / "outputfiles-x264" / f"{bitrate}k" / name
        route_dir.mkdir(parents=True)
        (route_dir / f"log_{name}_{bitrate}k_1.txt").write_text(
            "encoded 1 frames, 12.50 fps, 2000.00 kb/s\n", encoding="utf-8"
        )
        (route_dir / f"{name}_{bitrate}k_1.bin").write_bytes(b"1234")
    raw_output = tmp_path / "raw.log"
    raw_output.write_text("original command output\n", encoding="utf-8")
    assert len(reference.collect("x264", tmp_path, raw_output, selected_rows, videos)) == 6

    csv_path.write_text(header + rows.rsplit("\n", 2)[0] + "\n", encoding="utf-8")
    with pytest.raises(ValueError, match="rows differ"):
        reference.read_summary(csv_path, set(videos))


def test_video_subset_rejects_empty_or_unknown_inputs(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(reference, "VIDEO_NAMES", ("known",))
    monkeypatch.setattr(reference, "FRAME_BYTES", 6)
    with pytest.raises(ValueError, match="no YUV inputs"):
        reference.inspect_videos(tmp_path, allow_subset=True)
    (tmp_path / "unknown.yuv").write_bytes(b"123456")
    with pytest.raises(ValueError, match="extra=.*unknown"):
        reference.inspect_videos(tmp_path, allow_subset=True)


@pytest.mark.parametrize("encoder", ("x264", "x265"))
def test_both_encoders_accept_three_video_subset_at_stage_check(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, encoder: str
) -> None:
    monkeypatch.setattr(reference, "VIDEO_NAMES", ("one", "two", "three", "four"))
    monkeypatch.setattr(reference, "FRAME_BYTES", 6)
    for name in ("one", "two", "three"):
        (tmp_path / f"{name}.yuv").write_bytes(b"123456")
    monkeypatch.setattr(
        reference.sys,
        "argv",
        [
            "collect_reference.py",
            "--check-only",
            "--encoder",
            encoder,
            "--allow-video-subset",
            "--video-dir",
            str(tmp_path),
        ],
    )
    assert reference.main() == 0
