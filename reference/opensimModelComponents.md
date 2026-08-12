# List Core OpenSim Model Component Names

List Core OpenSim Model Component Names

## Usage

``` r
opensimModelComponents(model)
```

## Arguments

- model:

  A `PhysioOpenSimModel` external pointer.

## Value

Named list with vectors for body, joint, marker, muscle, and coordinate
names.

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
comps <- opensimModelComponents(model)
comps$bodies
comps$muscles
} # }
```
