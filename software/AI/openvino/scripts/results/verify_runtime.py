#!/usr/bin/env python3
"""Verify the pinned OpenVINO/PyTorch/ONNX runtime inside the container."""

from __future__ import annotations

from importlib.metadata import version

import onnx
import PIL
import numpy
import openvino
import torch
import torchvision

assert torch.__version__.split("+")[0] == "2.9.1", torch.__version__
assert torchvision.__version__.split("+")[0] == "0.24.1", torchvision.__version__
assert version("openvino") == "2026.2.1", version("openvino")
assert onnx.__version__ == "1.19.1", onnx.__version__
assert numpy.__version__ == "2.4.6", numpy.__version__
assert PIL.__version__ == "13.0.0", PIL.__version__

print("torch", torch.__version__, "torchvision", torchvision.__version__)
print("openvino", version("openvino"), "onnx", onnx.__version__)
print("numpy", numpy.__version__, "pillow", PIL.__version__)
