#!/usr/bin/env python3
"""Optional adapter interface for cases that cannot use the command adapter."""

from __future__ import annotations

from abc import ABC, abstractmethod

from context import RunContext


class SoftwareAdapter(ABC):
    def __init__(self, context: RunContext) -> None:
        self.context = context

    @abstractmethod
    def build(self) -> None:
        """Build, install, and validate the software."""

    @abstractmethod
    def start(self) -> None:
        """Start the software service and wait until it is ready."""

    @abstractmethod
    def test(self) -> None:
        """Run benchmarks and write the declared software result files."""

    @abstractmethod
    def stop(self) -> None:
        """Idempotently stop the software service and verify it exited."""
