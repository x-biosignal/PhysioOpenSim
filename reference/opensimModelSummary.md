# Summarize an OpenSim Model via Native C++ API

Loads an `.osim` model (or uses a loaded model handle) and returns
structural summary information.

## Usage

``` r
opensimModelSummary(path)
```

## Arguments

- path:

  Path to an OpenSim model file (`.osim`) or a `PhysioOpenSimModel`
  external pointer.

## Value

A named list with model metadata (`model_name`, `n_bodies`, `n_joints`,
`n_markers`, `n_muscles`, `n_coordinates`, `total_mass`, `initialized`).

## Examples

``` r
if (FALSE) { # \dontrun{
info <- opensimModelSummary("gait2392.osim")
info$model_name
info$n_muscles

# Also works with a loaded model handle
model <- opensimLoadModel("gait2392.osim")
opensimModelSummary(model)
} # }
```
