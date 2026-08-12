# Write ID Setup XML from Template

Convenience wrapper around
[`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md)
for common Inverse Dynamics tags.

## Usage

``` r
opensimWriteIDSetupFromTemplate(
  template_file,
  output_file,
  model_file,
  coordinates_file,
  output_gen_force_file,
  external_loads_file = NULL,
  time_range = NULL,
  lowpass_cutoff_frequency_for_coordinates = NULL,
  results_directory = NULL,
  extra_fields = list(),
  strict = TRUE
)
```

## Arguments

- template_file:

  Path to ID template XML.

- output_file:

  Path to output ID setup XML.

- model_file:

  Path to `.osim` model.

- coordinates_file:

  Path to coordinates/motion file (typically `.mot`).

- output_gen_force_file:

  Path to generalized force output file (`.sto`).

- external_loads_file:

  Optional path to external loads XML.

- time_range:

  Optional numeric length-2 vector (`c(start, end)`).

- lowpass_cutoff_frequency_for_coordinates:

  Optional numeric cutoff.

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
opensimWriteIDSetupFromTemplate(
  template_file = "id_template.xml",
  output_file = "id_setup.xml",
  model_file = "gait2392.osim",
  coordinates_file = "ik_output.mot",
  output_gen_force_file = "id_output.sto",
  time_range = c(0.5, 2.0)
)
} # }
```
