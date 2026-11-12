#!/usr/bin/env python3
"""Verify the pinned CPU PyTorch/torchvision runtime inside the container."""

from __future__ import annotations

import PIL
import numpy
import torch
import torchvision

assert torch.__version__.split("+")[0] == "2.9.1", torch.__version__
assert torchvision.__version__.split("+")[0] == "0.24.1", torchvision.__version__
assert numpy.__version__ == "2.4.6", numpy.__version__
assert PIL.__version__ == "13.0.0", PIL.__version__

print("torch", torch.__version__, "torchvision", torchvision.__version__)
print("numpy", numpy.__version__, "pillow", PIL.__version__)
print("quantized engine default", torch.backends.quantized.engine)
