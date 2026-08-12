# Set OpenSim Model Name

Set OpenSim Model Name

## Usage

``` r
opensimSetModelName(model, name)
```

## Arguments

- model:

  A `PhysioOpenSimModel` external pointer.

- name:

  New model name.

## Value

The input `model` handle (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
opensimSetModelName(model, "my_model")
opensimModelName(model)  # "my_model"
} # }
```
