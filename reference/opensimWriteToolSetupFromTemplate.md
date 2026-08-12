# Write OpenSim Tool Setup XML from Template

Replaces tag values in an existing OpenSim setup XML template. This
function is tool-agnostic and can be used for IK/ID/SO/RRA/CMC
templates.

## Usage

``` r
opensimWriteToolSetupFromTemplate(
  template_file,
  output_file,
  fields,
  strict = TRUE
)
```

## Arguments

- template_file:

  Path to template XML.

- output_file:

  Path to output XML.

- fields:

  Named list of replacement values keyed by XML tag name.

- strict:

  If `TRUE`, error when a tag in `fields` is missing in template.

## Value

A named list with `output_file`, `applied_tags`, and `missing_tags`.

## Examples

``` r
# Create a minimal template in a temp file
tpl <- tempfile(fileext = ".xml")
writeLines(c(
  "<OpenSimDocument>",
  "  <model_file>Unassigned</model_file>",
  "  <time_range>0 1</time_range>",
  "</OpenSimDocument>"
), tpl)

out <- tempfile(fileext = ".xml")
result <- opensimWriteToolSetupFromTemplate(
  template_file = tpl,
  output_file = out,
  fields = list(model_file = "my_model.osim", time_range = "0.5 2.0")
)
result$applied_tags
#> [1] "model_file" "time_range"
readLines(result$output_file)
#> [1] "<OpenSimDocument>"                       
#> [2] "  <model_file>my_model.osim</model_file>"
#> [3] "  <time_range>0.5 2.0</time_range>"      
#> [4] "</OpenSimDocument>"                      
```
