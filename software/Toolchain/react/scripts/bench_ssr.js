#!/usr/bin/env node
"use strict";

/*
 * Deterministic React 19 server-rendering harness.
 *
 * One process performs one scenario: build the element tree once, run the fixed
 * warmup, then time a fixed number of renders with a monotonic clock. The result
 * JSON is the per-repetition evidence; the adapter records the process wall time
 * and peak RSS next to it.
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const TASKS = {
    render_to_string: { api: "renderToString", mode: "sync" },
    static_markup: { api: "renderToStaticMarkup", mode: "sync" },
    stream: { api: "renderToPipeableStream", mode: "stream" },
};

function fail(message) {
    process.stderr.write(`[react-bench] ERROR: ${message}\n`);
    process.exit(2);
}

function parseArguments(argv) {
    const options = {};
    for (let index = 2; index < argv.length; index += 2) {
        const flag = argv[index];
        if (!flag.startsWith("--")) {
            fail(`unexpected argument: ${flag}`);
        }
        const value = argv[index + 1];
        if (value === undefined) {
            fail(`missing value for ${flag}`);
        }
        options[flag.slice(2)] = value;
    }
    return options;
}

function positiveInteger(options, name, required) {
    const raw = options[name];
    if (raw === undefined) {
        if (required) {
            fail(`missing required argument --${name}`);
        }
        return 0;
    }
    if (!/^[1-9][0-9]*$/.test(raw)) {
        fail(`--${name} must be a positive integer, got ${raw}`);
    }
    return Number(raw);
}

function readVersion(moduleName) {
    return require(`${moduleName}/package.json`).version;
}

function buildTree(React, items) {
    const rows = new Array(items);
    for (let index = 0; index < items; index += 1) {
        rows[index] = React.createElement(
            "li",
            {
                key: String(index),
                className: index % 2 === 0 ? "even" : "odd",
                "data-index": String(index),
            },
            `item ${index}`
        );
    }
    return React.createElement(
        "ul",
        { className: "list", "data-size": String(items) },
        rows
    );
}

function countListItems(markup) {
    return markup.split("<li").length - 1;
}

function summarizePerRender(durationsSeconds) {
    const milliseconds = durationsSeconds
        .map((seconds) => seconds * 1000)
        .sort((left, right) => left - right);
    const count = milliseconds.length;
    const mean = milliseconds.reduce((total, value) => total + value, 0) / count;
    const median =
        count % 2 === 1
            ? milliseconds[(count - 1) / 2]
            : (milliseconds[count / 2 - 1] + milliseconds[count / 2]) / 2;
    const variance =
        milliseconds.reduce((total, value) => total + (value - mean) ** 2, 0) / count;
    return {
        min: Number(milliseconds[0].toFixed(6)),
        median: Number(median.toFixed(6)),
        mean: Number(mean.toFixed(6)),
        max: Number(milliseconds[count - 1].toFixed(6)),
        stdev: Number(Math.sqrt(variance).toFixed(6)),
    };
}

function syncRenderer(render) {
    return {
        async warmup(renderCount) {
            for (let index = 0; index < renderCount; index += 1) {
                render();
            }
        },
        async timed(renderCount) {
            const durations = new Array(renderCount);
            let bytes = 0;
            let firstMarkup = "";
            const startedAt = process.hrtime.bigint();
            for (let index = 0; index < renderCount; index += 1) {
                const iterationStart = process.hrtime.bigint();
                const markup = render();
                durations[index] = Number(process.hrtime.bigint() - iterationStart) / 1e9;
                bytes += markup.length;
                if (index === 0) {
                    firstMarkup = markup;
                }
            }
            const elapsed = Number(process.hrtime.bigint() - startedAt) / 1e9;
            return { elapsed, durations, bytes, firstMarkup };
        },
    };
}

function streamRenderer(React, renderToPipeableStream, tree) {
    const { Writable } = require("stream");
    const drain = (collectMarkup) =>
        new Promise((resolve, reject) => {
            let bytes = 0;
            let firstChunk = "";
            const chunks = collectMarkup ? [] : null;
            const sink = new Writable({
                write(chunk, _encoding, callback) {
                    if (typeof chunk === "string") {
                        bytes += Buffer.byteLength(chunk);
                        if (!firstChunk) {
                            firstChunk = chunk;
                        }
                        if (chunks) {
                            chunks.push(chunk);
                        }
                    } else {
                        bytes += chunk.length;
                        if (!firstChunk) {
                            firstChunk = chunk.toString("utf8");
                        }
                        if (chunks) {
                            chunks.push(chunk.toString("utf8"));
                        }
                    }
                    callback();
                },
            });
            const stream = renderToPipeableStream(tree, {
                onAllReady() {
                    stream.pipe(sink);
                },
                onError(error) {
                    reject(error);
                },
            });
            sink.on("finish", () =>
                resolve({ bytes, firstChunk, markup: chunks ? chunks.join("") : "" })
            );
            sink.on("error", reject);
        });
    return {
        async warmup(renderCount) {
            for (let index = 0; index < renderCount; index += 1) {
                await drain(false);
            }
        },
        async timed(renderCount) {
            const durations = new Array(renderCount);
            let bytes = 0;
            let firstMarkup = "";
            const startedAt = process.hrtime.bigint();
            for (let index = 0; index < renderCount; index += 1) {
                const iterationStart = process.hrtime.bigint();
                const result = await drain(index === 0);
                durations[index] = Number(process.hrtime.bigint() - iterationStart) / 1e9;
                bytes += result.bytes;
                if (index === 0) {
                    firstMarkup = result.markup;
                }
            }
            const elapsed = Number(process.hrtime.bigint() - startedAt) / 1e9;
            return { elapsed, durations, bytes, firstMarkup };
        },
    };
}

async function main() {
    const options = parseArguments(process.argv);
    const taskName = options.task;
    if (!taskName || !TASKS[taskName]) {
        fail(`--task must be one of ${Object.keys(TASKS).join(", ")}`);
    }
    const task = TASKS[taskName];
    const items = positiveInteger(options, "items", true);
    const renders = positiveInteger(options, "renders", true);
    const warmupRenders = positiveInteger(options, "warmup", true);
    const outputPath = options.output;
    if (!outputPath) {
        fail("missing required argument --output");
    }
    if (process.env.NODE_ENV !== "production") {
        fail(`NODE_ENV must be production for measured renders, got ${process.env.NODE_ENV || "<unset>"}`);
    }

    const React = require("react");
    const ReactDOMServer = require("react-dom/server");
    if (typeof ReactDOMServer[task.api] !== "function") {
        fail(`react-dom/server does not expose ${task.api}`);
    }
    const tree = buildTree(React, items);
    const renderer =
        task.mode === "sync"
            ? syncRenderer(() => ReactDOMServer[task.api](tree))
            : streamRenderer(React, ReactDOMServer[task.api], tree);

    const startedAt = new Date().toISOString();
    await renderer.warmup(warmupRenders);
    const measured = await renderer.timed(renders);
    const finishedAt = new Date().toISOString();
    const elapsed = measured.elapsed;
    if (!Number.isFinite(elapsed) || elapsed <= 0) {
        fail(`measured elapsed time is invalid: ${elapsed}`);
    }
    const listItems = countListItems(measured.firstMarkup);
    if (listItems !== items) {
        fail(`rendered markup contains ${listItems} list items, expected ${items}`);
    }
    const result = {
        recorded_at: finishedAt,
        task: taskName,
        api: task.api,
        mode: task.mode,
        items,
        renders,
        warmup_renders: warmupRenders,
        batch_seconds: Number(elapsed.toFixed(9)),
        renders_per_second: Number((renders / elapsed).toFixed(3)),
        per_render_ms: summarizePerRender(measured.durations),
        markup_sha256: crypto
            .createHash("sha256")
            .update(measured.firstMarkup, "utf8")
            .digest("hex"),
        markup_bytes_first: Buffer.byteLength(measured.firstMarkup, "utf8"),
        batch_bytes: measured.bytes,
        list_items: listItems,
        node_version: process.version,
        node_env: process.env.NODE_ENV,
        react_version: readVersion("react"),
        react_dom_version: readVersion("react-dom"),
        scheduler_version: readVersion("scheduler"),
        started_at: startedAt,
    };
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, `${JSON.stringify(result, null, 2)}\n`, "utf8");
    process.stdout.write(
        `[react-bench] ${taskName} items=${items} renders=${renders} ` +
            `batch=${elapsed.toFixed(6)}s rps=${(renders / elapsed).toFixed(1)} ` +
            `bytes=${measured.bytes} sha256=${result.markup_sha256.slice(0, 12)}\n`
    );
}

main().catch((error) => {
    process.stderr.write(`[react-bench] FATAL: ${error && error.stack ? error.stack : error}\n`);
    process.exit(1);
});
