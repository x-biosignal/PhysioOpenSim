# Write IK Setup XML from Template

Convenience wrapper around
[`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md)
for common Inverse Kinematics tags.

## Usage

``` r
opensimWriteIKSetupFromTemplate(
  template_file,
  output_file,
  model_file,
  marker_file,
  output_motion_file,
  time_range = NULL,
  results_directory = NULL,
  extra_fields = list(),
  strict = TRUE
)
```

## Arguments

- template_file:

  Path to IK template XML.

- output_file:

  Path to output IK setup XML.

- model_file:

  Path to `.osim` model.

- marker_file:

  Path to marker trajectory file (typically `.trc`).

- output_motion_file:

  Path to IK output motion file (`.mot`).

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
opensimWriteIKSetupFromTemplate(
  template_file = "ik_template.xml",
  output_file = "ik_setup.xml",
  model_file = "gait2392.osim",
  marker_file = "walking.trc",
  output_motion_file = "ik_output.mot",
  time_range = c(0.5, 2.0)
)
} # }
```
