"""Synthetic checks for the AccLibBenchmark adapter; no RPC workload runs."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace


SCRIPT = Path(__file__).with_name("run_acclib.py")
SPEC = importlib.util.spec_from_file_location("folly_acclib_adapter", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AccLibAdapterTest(unittest.TestCase):
    def test_matrix_result_and_port_is_runtime_only(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            private_root = root / "AccLibBenchmark"
            run_py = private_root / "fb_folly_autobuild" / "run.py"
            run_py.parent.mkdir(parents=True)
            run_py.write_text("# fixture\n", encoding="utf-8")
            source = private_root / "fbthrift_folly_benchmark"
            for relative in ("CMakeLists.txt", "server/PressServer.cpp",
                             "client/PressTestClient.cpp", "press.thrift"):
                path = source / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(relative, encoding="utf-8")
            binary = root / "press_client"
            binary.write_text(
                "#!/bin/sh\n"
                "printf 'Success: 10\\nFail: 0\\nQPS: 10.00\\n"
                "Throughput: 2.50MB/s\\nLatency (us): avg=11.00 p99=20.00\\n"
                "Server CPU (%%): avg=4.00\\nClient CPU (%%): avg=5.00\\n'\n",
                encoding="utf-8",
            )
            binary.chmod(0o755)
            original = SimpleNamespace(
                EXECUTABLE="/reference/press_client",
                PREFIX_CMD=["numactl", "-N", "0", "/reference/press_client",
                            "--host=192.0.2.1", "--port=23456", "--test_seconds=90",
                            "--transport=rocket", "--use_io_uring=false"],
                DATA_SETUPS=[["binary payload", ["--fields=none", "--payload_size=256"]]],
                CONN_SETUPS=[[1, 1, 50]], QD_SETUPS=[10],
                parse_output=lambda _output: {
                    "Throughput": "2.50MB/s", "latencyAvg": "11.00",
                    "latencyP99": "20.00", "Server CPU (%)": "4.00",
                    "Client CPU (%)": "5.00",
                },
            )
            result_path = root / "results" / "benchmark_folly.json"
            MODULE.run(original, run_py, binary, 41000, result_path,
                       result_path.parent / "press_client_raw", "2022.11.14.00", "x86_64")
            payload = json.loads(result_path.read_text(encoding="utf-8"))
            self.assertEqual(len(payload["results"]), 6)
            self.assertEqual(payload["parameters"]["cases"], 1)
            self.assertNotIn("port", payload["parameters"])
            self.assertEqual(payload["runtime_context"]["port"], 41000)
            self.assertTrue(all("binary payload / payload=256B" in name
                                for name in payload["results"]))

    def test_failed_rpc_is_rejected(self):
        original = SimpleNamespace(parse_output=lambda _output: {
            "Throughput": "2.50MB/s", "latencyAvg": "11.00", "latencyP99": "20.00",
            "Server CPU (%)": "4.00", "Client CPU (%)": "5.00",
        })
        with self.assertRaisesRegex(RuntimeError, "Fail=1"):
            MODULE.measurement_rows(
                "Success: 10\nFail: 1\nQPS: 10.00\nThroughput: 2.50MB/s\n"
                "Latency (us): avg=11.00 p99=20.00\n", original
            )


if __name__ == "__main__":
    unittest.main()
