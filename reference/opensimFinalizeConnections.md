# Finalize OpenSim Model Connections

Finalize OpenSim Model Connections

## Usage

``` r
opensimFinalizeConnections(model)
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
opensimFinalizeConnections(model)
} # }
```
