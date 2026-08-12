# Run an OpenSim Tool Setup XML

Executes a setup XML through native OpenSim bindings (when available) or
through OpenSim CLI.

## Usage

``` r
opensimRunTool(
  setup_file,
  workdir = NULL,
  cli = NULL,
  extra_args = character(),
  timeout_sec = 0L,
  fail_on_error = TRUE,
  execution = c("auto", "native", "cli"),
  tool_type = c("tool", "ik", "id", "so", "analyze", "cmc", "rra")
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

- tool_type:

  Tool flavor token: `"tool"` (generic), `"ik"`, `"id"`, or `"so"`,
  `"analyze"`, `"cmc"`, `"rra"`.

## Value

A named list with command metadata and logs.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- opensimRunTool("ik_setup.xml")
result$status
result$stdout

# Force CLI backend with extra arguments
opensimRunTool("ik_setup.xml", execution = "cli",
               extra_args = "--visualize")
} # }
```
