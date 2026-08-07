#!/usr/bin/env python3
"""Generate a minimal JUnit report from normalized task results."""

from __future__ import annotations

from xml.etree.ElementTree import Element, SubElement, tostring


def render(results: list[dict]) -> str:
    failures = sum(1 for result in results if result.get("status") != "passed")
    suite = Element("testsuite", name="performance", tests=str(len(results)), failures=str(failures))
    for result in results:
        case = SubElement(
            suite,
            "testcase",
            classname=f"{result.get('category')}.{result.get('software')}",
            name=f"{result.get('version')}.{result.get('architecture')}",
        )
        if result.get("status") != "passed":
            failure = SubElement(case, "failure", message="performance task failed")
            failure.text = str(result.get("status"))
    return tostring(suite, encoding="unicode") + "\n"
