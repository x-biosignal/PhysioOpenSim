# Load an OpenSim Model as a Native External Pointer

Load an OpenSim Model as a Native External Pointer

## Usage

``` r
opensimLoadModel(path)
```

## Arguments

- path:

  Path to an OpenSim model file (`.osim`).

## Value

A `PhysioOpenSimModel` external pointer handle.

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
opensimModelName(model)
} # }
```
