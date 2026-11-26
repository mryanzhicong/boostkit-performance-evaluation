#!/usr/bin/env Rscript
# Deterministic R workload matrix.
#
# Usage: Rscript bench.R <scenario> <scale> [label]
#
# Every scenario performs a deterministic amount of work derived from <scale>
# and prints exactly one line:
#
#     RESULT scenario=<name> checksum=<value>
#
# The parser in scripts/results/parse_benchmark.py validates that line against
# the committed expected value, so an accidental workload or interpreter change
# fails the case instead of silently producing different numbers.  The BLAS
# scenarios use the internal reference BLAS/LAPACK that ships with the R source
# (no external BLAS is installed or linked, see scripts/common.sh).

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("usage: bench.R <scenario> <scale> [label]")
}
scenario <- args[[1]]
scale <- if (length(args) >= 2) as.integer(args[[2]]) else 1L
if (is.na(scale) || scale < 1L) scale <- 1L
label <- if (length(args) >= 3) args[[3]] else "run"

set.seed(20261102)

base <- sub("_(small|large)$", "", scenario)

is_float <- FALSE
checksum <- NULL

if (base == "crossprod") {
  n <- scale
  matrix_a <- matrix(runif(n * n), nrow = n, ncol = n)
  product <- crossprod(matrix_a)
  checksum <- sum(product)
  is_float <- TRUE
} else if (base == "matvec") {
  n <- scale
  matrix_a <- matrix(runif(n * n), nrow = n, ncol = n)
  vector_b <- runif(n)
  product <- matrix_a %*% vector_b
  checksum <- sum(product)
  is_float <- TRUE
} else if (base == "solve") {
  n <- scale
  matrix_a <- matrix(runif(n * n), nrow = n, ncol = n)
  matrix_a <- matrix_a %*% t(matrix_a) + diag(n)
  vector_b <- runif(n)
  solution <- solve(matrix_a, vector_b)
  checksum <- sum(solution)
  is_float <- TRUE
} else if (base == "vector_arith") {
  values <- seq_len(scale)
  checksum <- sum(sqrt(values) + values / 7)
  is_float <- TRUE
} else if (base == "sort") {
  values <- runif(scale)
  ordered <- sort(values)
  checksum <- sum(ordered)
  is_float <- TRUE
} else if (base == "lapply") {
  values <- unlist(lapply(seq_len(scale), function(i) (i * 7L) %% 1000003L))
  checksum <- sum(values)
} else if (base == "paste") {
  values <- paste0("prefix_", seq_len(scale))
  checksum <- sum(nchar(values))
} else if (base == "rowsum") {
  nrow <- scale
  ncol <- 100L
  values <- matrix(runif(nrow * ncol), nrow = nrow, ncol = ncol)
  checksum <- sum(rowSums(values))
  is_float <- TRUE
} else {
  stop(paste("unknown scenario:", scenario))
}

if (is_float) {
  cat(sprintf("RESULT scenario=%s checksum=%.12f\n", scenario, as.numeric(checksum)))
} else {
  cat(sprintf("RESULT scenario=%s checksum=%.0f\n", scenario, as.numeric(checksum)))
}
