# Getting Started with PhysioOpenSim

## Overview

PhysioOpenSim provides an R interface to
[OpenSim](https://opensim.stanford.edu/) for biomechanics simulation and
analysis. The package supports two execution backends:

- **Native** – OpenSim C++ libraries linked at compile time (fastest)
- **CLI** – OpenSim command-line tool invoked as an external process
  (most portable)

Both backends are accessed through the same high-level R functions, so
user code does not need to change when switching backends.

## Checking Your Build

Start by verifying what capabilities are available in your installation.

``` r

library(PhysioOpenSim)

# Native C++ support compiled in?
opensimAvailable()
#> [1] FALSE

# Detailed build configuration
cfg <- opensimBuildConfig()
str(cfg)
#> List of 3
#>  $ package        : chr "PhysioOpenSim"
#>  $ opensim_enabled: logi FALSE
#>  $ detect_method  : chr "none"
```

``` r

# Is the OpenSim CLI on your PATH?
opensimCLIAvailable()
#> [1] FALSE
```

If neither backend is available, you can still use the template system
(described below) to prepare OpenSim setup files for later execution.

## Working with Models (Native Backend)

When native support is available, you can load and inspect `.osim` model
files directly in R.

``` r

# Load a model
model <- opensimLoadModel("gait2392.osim")

# Inspect the model
opensimModelName(model)
info <- opensimModelSummary(model)
str(info)
# List of 8
#  $ model_name   : chr "gait2392"
#  $ n_bodies     : int 14
#  $ n_joints     : int 13
#  $ n_markers    : int 35
#  $ n_muscles    : int 92
#  $ n_coordinates: int 37
#  $ total_mass   : num 75.2
#  $ initialized  : logi FALSE

# Component names
comps <- opensimModelComponents(model)
head(comps$muscles)

# Modify and save
opensimSetModelName(model, "my_custom_model")
opensimModelInitialize(model)
opensimSaveModel(model, "my_custom_model.osim")
```

## Template-Based Setup

The template system lets you generate OpenSim tool setup XMLs from a
template by replacing specific XML tag values. This works without any
OpenSim installation.

``` r

# Create a simple template
tpl <- tempfile(fileext = ".xml")
writeLines(c(
  '<?xml version="1.0" encoding="UTF-8" ?>',
  "<OpenSimDocument>",
  "  <InverseKinematicsTool>",
  "    <model_file>Unassigned</model_file>",
  "    <marker_file>Unassigned</marker_file>",
  "    <time_range>0 1</time_range>",
  "  </InverseKinematicsTool>",
  "</OpenSimDocument>"
), tpl)

# Generate a configured setup file
out <- tempfile(fileext = ".xml")
result <- opensimWriteToolSetupFromTemplate(
  template_file = tpl,
  output_file = out,
  fields = list(
    model_file = "gait2392.osim",
    marker_file = "walking_trial.trc",
    time_range = "0.5 2.0"
  )
)

# What was applied?
result$applied_tags
#> [1] "model_file"  "marker_file" "time_range"
result$missing_tags
#> character(0)

# Inspect the output
cat(readLines(result$output_file), sep = "\n")
#> <?xml version="1.0" encoding="UTF-8" ?>
#> <OpenSimDocument>
#>   <InverseKinematicsTool>
#>     <model_file>gait2392.osim</model_file>
#>     <marker_file>walking_trial.trc</marker_file>
#>     <time_range>0.5 2.0</time_range>
#>   </InverseKinematicsTool>
#> </OpenSimDocument>
```

### Strict vs. Non-Strict Mode

By default, `strict = TRUE` causes an error if any requested tag is not
found in the template. Use `strict = FALSE` for partial replacements.

``` r

tpl2 <- tempfile(fileext = ".xml")
writeLines(c(
  "<root>",
  "  <model_file>old</model_file>",
  "</root>"
), tpl2)

# This would error with strict = TRUE:
out2 <- tempfile(fileext = ".xml")
result2 <- suppressWarnings(
  opensimWriteToolSetupFromTemplate(
    template_file = tpl2,
    output_file = out2,
    fields = list(model_file = "new.osim", nonexistent_tag = "value"),
    strict = FALSE
  )
)
result2$applied_tags
#> [1] "model_file"
result2$missing_tags
#> [1] "nonexistent_tag"
```

## Running Tools

Once you have a setup XML, run it through OpenSim.

``` r

# Auto-selects native or CLI backend
result <- opensimRunTool("ik_setup.xml")
result$status    # 0 = success
result$stdout
result$stderr

# Force CLI with extra arguments
result <- opensimRunTool(
  "ik_setup.xml",
  execution = "cli",
  extra_args = c("--visualize"),
  timeout_sec = 120
)
```

Typed wrappers are available for common tools:

``` r

opensimRunIK("ik_setup.xml")
opensimRunID("id_setup.xml")
opensimRunSO("so_setup.xml")
opensimRunAnalyze("analyze_setup.xml")
opensimRunRRA("rra_setup.xml")
opensimRunCMC("cmc_setup.xml")
```

## Backend Selection Guide

| Scenario                         | Recommended Backend                 |
|----------------------------------|-------------------------------------|
| Batch processing, speed critical | Native                              |
| No OpenSim SDK installed locally | CLI                                 |
| Need `extra_args` for CLI flags  | CLI                                 |
| Generic `tool_type = "tool"`     | CLI (native requires specific type) |
| Default (let the package decide) | `execution = "auto"`                |
