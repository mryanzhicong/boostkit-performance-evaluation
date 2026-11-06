#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
stop_spark_runtime() { remove_spark_container; }
