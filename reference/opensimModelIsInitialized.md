# Check Whether an OpenSim Model Handle Is Initialized

Check Whether an OpenSim Model Handle Is Initialized

## Usage

``` r
opensimModelIsInitialized(model)
```

## Arguments

- model:

  A `PhysioOpenSimModel` external pointer.

## Value

`TRUE` when model state has been initialized by OpenSim.

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
opensimModelIsInitialized(model)
} # }
```
