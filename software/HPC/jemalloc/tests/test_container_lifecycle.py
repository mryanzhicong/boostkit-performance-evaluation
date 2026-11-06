"""Keep the framework stages on the same task-owned container."""

from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"


def test_only_build_loads_image_and_starts_container() -> None:
    build = (SCRIPTS / "builders/base.sh").read_text(encoding="utf-8")
    start = (SCRIPTS / "stages/start.sh").read_text(encoding="utf-8")
    test = (SCRIPTS / "stages/test.sh").read_text(encoding="utf-8")
    stop = (SCRIPTS / "stages/stop.sh").read_text(encoding="utf-8")

    assert "jemalloc_load_image" in build
    assert "jemalloc_start_container" in build
    assert "jemalloc_load_image" not in start + test
    assert "jemalloc_start_container" not in start + test
    assert "jemalloc_existing_container" in start
    assert "jemalloc_existing_container" in test
    assert "jemalloc_stop_container" in stop
