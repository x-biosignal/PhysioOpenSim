# Initialize OpenSim Model System State

Initialize OpenSim Model System State

## Usage

``` r
opensimModelInitialize(model)
```

## Arguments

- model:

  A `PhysioOpenSimModel` external pointer.

## Value

The input `model` handle (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
opensimModelInitialize(model)
opensimModelIsInitialized(model)  # TRUE
} # }
```
