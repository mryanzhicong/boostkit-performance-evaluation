#!/usr/bin/env bash
# The optimized variant is not implemented for this case.  It must fail loudly
# and must not fall back to the base build or write build_variant.json, so that
# selecting it in the workflow can never silently run the base measurement.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_pcre_optimized() {
    fail_message "the optimized PCRE build variant is not implemented"
    return 30
}
