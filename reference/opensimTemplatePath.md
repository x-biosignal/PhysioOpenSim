# Path to a bundled OpenSim setup-template XML

Returns the path of a setup-template XML shipped with PhysioOpenSim,
suitable as the `template_file` argument of the
`opensimWrite*SetupFromTemplate()` functions. Each template is a minimal
OpenSim tool document whose fields (model, marker/coordinates, output,
time range, external loads) are substituted by those writers.

## Usage

``` r
opensimTemplatePath(
  tool = c("ik", "id", "so", "cmc", "rra", "analyze", "generic")
)
```

## Arguments

- tool:

  Which tool template to return: one of `"ik"`, `"id"`, `"so"`, `"cmc"`,
  `"rra"`, `"analyze"`, `"generic"`.

## Value

An absolute path to the bundled `<tool>_setup_template.xml`.

## See also

[`opensimWriteIKSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIKSetupFromTemplate.md),
[`opensimWriteIDSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIDSetupFromTemplate.md),
[`opensimWriteSOSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteSOSetupFromTemplate.md)

## Examples

``` r
opensimTemplatePath("ik")
#> [1] "/home/runner/work/_temp/Library/PhysioOpenSim/extdata/ik_setup_template.xml"
```
