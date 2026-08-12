# Save OpenSim Model to File

Save OpenSim Model to File

## Usage

``` r
opensimSaveModel(model, output_file)
```

## Arguments

- model:

  A `PhysioOpenSimModel` external pointer.

- output_file:

  Output path for model XML.

## Value

Normalized output path.

## Examples

``` r
if (FALSE) { # \dontrun{
model <- opensimLoadModel("gait2392.osim")
opensimSetModelName(model, "modified")
opensimSaveModel(model, "gait2392_modified.osim")
} # }
```
