#!/usr/bin/env python3
"""Deterministic, offline OpenAI-compatible mock used by the OpenViking case.

The upstream benchmark kit expects a real LLM and a real embedding service.
The adaptation runs on the private performance runners, which have no external
model credentials and must produce reproducible numbers, so this mock replaces
both endpoints with deterministic local implementations:

* ``POST /v1/embeddings`` returns a pseudo-random but text-deterministic unit
  vector of the requested dimension (FNV-1a seeded LCG).  Retrieval therefore
  exercises the real OpenViking vector path with stable vectors.
* ``POST /v1/chat/completions`` answers the memory-extraction prompts with a
  deterministic operations document that follows the JSON Schema embedded in the
  prompt itself (the extraction output contract).  By default one synthetic
  event operation is emitted, so the persist/index path of the write pipeline is
  exercised; ``--operations empty`` returns the empty skeleton instead.  Every
  other prompt (LoCoMo question answering) gets a deterministic canned answer;
  only the local pipeline timings are meaningful, never answer quality.

The server is dependency free (standard library only) so it can run inside the
openEuler container with the same interpreter as the harness.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DEFAULT_ANSWER = "Based on the provided context, the answer is not stated."


def _embedding(text: str, dimension: int) -> list[float]:
    """Return a deterministic, unit-length vector for one input text."""
    digest = hashlib.sha256(text.encode("utf-8", "surrogatepass")).digest()
    state = int.from_bytes(digest[:8], "big") | 1
    values: list[float] = []
    for _ in range(dimension):
        # 64-bit linear congruential generator; deterministic per text/position.
        state = (state * 6364136223846793005 + 1442695040888963407) & 0xFFFFFFFFFFFFFFFF
        values.append(((state >> 11) / float(1 << 53)) * 2.0 - 1.0)
    norm = math.sqrt(sum(value * value for value in values)) or 1.0
    return [value / norm for value in values]


def _iter_texts(value: object) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        texts: list[str] = []
        for item in value:
            if isinstance(item, str):
                texts.append(item)
            elif isinstance(item, dict) and isinstance(item.get("text"), str):
                texts.append(item["text"])
        return texts
    return [str(value)]


def _schema_from_prompt(messages: list[dict]) -> dict | None:
    """Find the pydantic JSON Schema embedded by the extraction contract."""
    combined: list[str] = []
    for message in messages:
        content = message.get("content")
        if isinstance(content, str):
            combined.append(content)
        elif isinstance(content, list):
            for part in content:
                if isinstance(part, dict) and isinstance(part.get("text"), str):
                    combined.append(part["text"])
    text = "\n".join(combined)
    marker = text.find("## Output Format")
    search_from = marker if marker >= 0 else 0
    position = text.find("```json", search_from)
    while position >= 0:
        end = text.find("```", position + len("```json"))
        if end < 0:
            break
        candidate = text[position + len("```json") : end].strip()
        try:
            document = json.loads(candidate)
        except ValueError:
            document = None
        if isinstance(document, dict) and isinstance(document.get("properties"), dict):
            return document
        position = text.find("```json", end)
    return None


def _operations(schema: dict, mode: str) -> str:
    properties = schema.get("properties") or {}
    skeleton: dict[str, list] = {name: [] for name in properties}
    skeleton.setdefault("delete_ids", [])
    if mode == "event" and "events" in properties:
        # One deterministic synthetic event: enough to drive the resolve, patch,
        # persist and vector-upsert stages of the write pipeline without copying
        # conversation content into long-term memory.
        skeleton["events"] = [
            {
                "page_id": 100,
                "event_name": "benchmark_pipeline_probe",
                "ranges": "0-1",
                "goal": "drive the OpenViking memory write pipeline",
                "summary": "Synthetic deterministic event produced by the offline benchmark provider mock.",
            }
        ]
    return json.dumps(skeleton, ensure_ascii=False)


def _answer(messages: list[dict], operations_mode: str = "event") -> str:
    schema = _schema_from_prompt(messages)
    if schema is not None:
        return _operations(schema, operations_mode)
    return DEFAULT_ANSWER


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "openviking-mock/1.0"

    def log_message(self, fmt: str, *args: object) -> None:  # noqa: D102
        if self.server.verbose:  # type: ignore[attr-defined]
            sys.stderr.write("[mock] " + fmt % args + "\n")
            sys.stderr.flush()

    def _read_json(self) -> dict:
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b"{}"
        try:
            body = json.loads(raw.decode("utf-8"))
        except ValueError:
            body = {}
        return body if isinstance(body, dict) else {}

    def _send_json(self, status: int, payload: dict) -> None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_sse(self, chunks: list[dict]) -> None:
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "close")
        self.end_headers()
        for chunk in chunks:
            self.wfile.write(("data: " + json.dumps(chunk, ensure_ascii=False) + "\n\n").encode("utf-8"))
            self.wfile.flush()
            time.sleep(0.001)
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()
        self.close_connection = True

    def do_GET(self) -> None:  # noqa: N802
        if self.path.rstrip("/") in {"", "/health", "/v1/health"}:
            self._send_json(200, {"status": "ok", "mock": True})
            return
        if self.path.rstrip("/") in {"/v1/models", "/models"}:
            self._send_json(
                200,
                {
                    "object": "list",
                    "data": [
                        {"id": "mock-chat", "object": "model", "owned_by": "benchmark"},
                        {"id": "mock-embedding", "object": "model", "owned_by": "benchmark"},
                    ],
                },
            )
            return
        self._send_json(404, {"error": {"message": "not found", "type": "invalid_request_error"}})

    def do_POST(self) -> None:  # noqa: N802
        path = self.path.rstrip("/")
        body = self._read_json()
        if path in {"/v1/embeddings", "/embeddings"}:
            self._handle_embeddings(body)
            return
        if path in {"/v1/chat/completions", "/chat/completions", "/v1/completions"}:
            self._handle_chat(body)
            return
        self._send_json(404, {"error": {"message": "not found", "type": "invalid_request_error"}})

    def _handle_embeddings(self, body: dict) -> None:
        texts = _iter_texts(body.get("input"))
        try:
            dimension = int(body.get("dimensions") or self.server.dimension)  # type: ignore[attr-defined]
        except (TypeError, ValueError):
            dimension = self.server.dimension  # type: ignore[attr-defined]
        dimension = max(1, min(dimension, 8192))
        data = [
            {"object": "embedding", "index": index, "embedding": _embedding(text, dimension)}
            for index, text in enumerate(texts)
        ]
        prompt_tokens = sum(max(1, len(text) // 4) for text in texts)
        self._send_json(
            200,
            {
                "object": "list",
                "data": data,
                "model": body.get("model") or "mock-embedding",
                "usage": {"prompt_tokens": prompt_tokens, "total_tokens": prompt_tokens},
            },
        )

    def _handle_chat(self, body: dict) -> None:
        messages = body.get("messages")
        if not isinstance(messages, list):
            messages = []
        content = _answer(messages, getattr(self.server, "operations_mode", "event"))
        model = body.get("model") or "mock-chat"
        created = int(time.time())
        completion_id = "chatcmpl-mock-%d" % created
        prompt_tokens = sum(len(str(message.get("content", ""))) for message in messages) // 4
        completion_tokens = max(1, len(content) // 4)
        usage = {
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "total_tokens": prompt_tokens + completion_tokens,
        }
        if body.get("stream"):
            base = {
                "id": completion_id,
                "object": "chat.completion.chunk",
                "created": created,
                "model": model,
            }
            first = dict(base, choices=[{"index": 0, "delta": {"role": "assistant", "content": content}, "finish_reason": None}])
            last = dict(base, choices=[{"index": 0, "delta": {}, "finish_reason": "stop"}])
            self._send_sse([first, last])
            return
        self._send_json(
            200,
            {
                "id": completion_id,
                "object": "chat.completion",
                "created": created,
                "model": model,
                "choices": [
                    {
                        "index": 0,
                        "message": {"role": "assistant", "content": content},
                        "finish_reason": "stop",
                    }
                ],
                "usage": usage,
            },
        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministic OpenAI-compatible mock service")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=19660)
    parser.add_argument("--dimension", type=int, default=1024)
    parser.add_argument(
        "--operations",
        choices=("event", "empty"),
        default="event",
        help="memory operations returned for extraction prompts (default: one synthetic event)",
    )
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    server.daemon_threads = True
    server.dimension = args.dimension  # type: ignore[attr-defined]
    server.operations_mode = args.operations  # type: ignore[attr-defined]
    server.verbose = args.verbose  # type: ignore[attr-defined]
    print(
        "mock OpenAI-compatible service on http://%s:%d (dimension=%d, operations=%s)"
        % (args.host, args.port, args.dimension, args.operations),
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
