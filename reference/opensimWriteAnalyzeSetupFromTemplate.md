# Write Analyze Setup XML from Template

Convenience wrapper around
[`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md)
for common AnalyzeTool tags.

## Usage

``` r
opensimWriteAnalyzeSetupFromTemplate(
  template_file,
  output_file,
  model_file,
  coordinates_file = NULL,
  external_loads_file = NULL,
  time_range = NULL,
  results_directory = NULL,
  extra_fields = list(),
  strict = TRUE
)
```

## Arguments

- template_file:

  Path to Analyze template XML.

- output_file:

  Path to output Analyze setup XML.

- model_file:

  Path to `.osim` model.

- coordinates_file:

  Optional path to coordinates/motion file.

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
opensimWriteAnalyzeSetupFromTemplate(
  template_file = "analyze_template.xml",
  output_file = "analyze_setup.xml",
  model_file = "gait2392.osim",
  coordinates_file = "ik_output.mot"
)
} # }
```
