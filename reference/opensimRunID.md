# Run OpenSim Inverse Dynamics Tool

Run OpenSim Inverse Dynamics Tool

## Usage

``` r
opensimRunID(
  setup_file,
  workdir = NULL,
  cli = NULL,
  extra_args = character(),
  timeout_sec = 0L,
  fail_on_error = TRUE,
  execution = c("auto", "native", "cli")
)
```

## Arguments

- setup_file:

  Path to OpenSim tool setup XML.

- workdir:

  Optional working directory.

- cli:

  Optional command or absolute path (CLI mode only).

- extra_args:

  Optional extra CLI args appended after setup file.

- timeout_sec:

  Timeout in seconds for CLI execution (0 disables timeout).

- fail_on_error:

  If `TRUE`, stop on non-zero exit status.

- execution:

  Execution backend: `"auto"` (default), `"native"`, `"cli"`.

## Value

See
[`opensimRunTool()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunTool.md).

## Examples

``` r
if (FALSE) { # \dontrun{
result <- opensimRunID("id_setup.xml")
result$status
} # }
```
