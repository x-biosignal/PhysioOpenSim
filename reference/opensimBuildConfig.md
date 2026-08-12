# Show Build Configuration for OpenSim Native Bridge

Show Build Configuration for OpenSim Native Bridge

## Usage

``` r
opensimBuildConfig()
```

## Value

A list containing compilation status and build metadata.

## Examples

``` r
cfg <- opensimBuildConfig()
cfg$package
#> [1] "PhysioOpenSim"
cfg$opensim_enabled
#> [1] FALSE
```
