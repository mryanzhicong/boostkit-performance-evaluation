#!/usr/bin/env python3
"""Optional adapter interface for cases that cannot use the command adapter."""

from __future__ import annotations

from abc import ABC, abstractmethod

from context import RunContext


class SoftwareAdapter(ABC):
    def __init__(self, context: RunContext) -> None:
        self.context = context

    @abstractmethod
    def run(self) -> None:
        """Run the existing software case and write expected outputs."""

    def cleanup(self) -> None:
        """Clean software-private processes. Global runner cleanup is external."""
