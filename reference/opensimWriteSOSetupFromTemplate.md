# Write SO Setup XML from Template

Convenience wrapper around
[`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md)
for common Static Optimization tags.

## Usage

``` r
opensimWriteSOSetupFromTemplate(
  template_file,
  output_file,
  model_file,
  coordinates_file,
  external_loads_file = NULL,
  time_range = NULL,
  results_directory = NULL,
  extra_fields = list(),
  strict = TRUE
)
```

## Arguments

- template_file:

  Path to SO template XML.

- output_file:

  Path to output SO setup XML.

- model_file:

  Path to `.osim` model.

- coordinates_file:

  Path to coordinates/motion file (typically `.mot`).

- external_loads_file:

  Optional path to external loads XML.

- time_range:

  Optional numeric length-2 vector (`c(start, end)`).

- results_directory:

  Optional output directory.

- extra_fields:

  Optional named list of additional XML tag replacements.

- strict:

  Passed to
  [`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md).

## Value

See
[`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md).

## Examples

``` r
if (FALSE) { # \dontrun{
opensimWriteSOSetupFromTemplate(
  template_file = "so_template.xml",
  output_file = "so_setup.xml",
  model_file = "gait2392.osim",
  coordinates_file = "ik_output.mot",
  time_range = c(0.5, 2.0)
)
} # }
```
