# Resolve OpenSim CLI Command Path

Resolves the command path used to invoke OpenSim CLI.

## Usage

``` r
opensimCLIPath(cli = NULL)
```

## Arguments

- cli:

  Optional command or absolute path. Defaults to `OPENSIM_CLI`
  environment variable, then `"opensim-cmd"`.

## Value

A character scalar path to executable command.

## Examples

``` r
if (FALSE) { # \dontrun{
opensimCLIPath()
opensimCLIPath("/usr/local/bin/opensim-cmd")
} # }
```
