# Report the OpenSim Integration Environment

Collects a single diagnostic snapshot of how this package can reach
OpenSim: whether the native bridge was compiled in and by which
detection method, whether the `opensim-cmd` CLI is on the search path,
and the OpenSim / Simbody versions reported by whichever backend is
available. Useful in CI logs and bug reports.

## Usage

``` r
opensimDiagnostics(cli = NULL)
```

## Arguments

- cli:

  Optional `opensim-cmd` command or path passed to
  [`opensimCLIAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIAvailable.md)
  /
  [`opensimCLIPath()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIPath.md).

## Value

An `opensim_diagnostics` list with elements `package`,
`native_available`, `detect_method`, `cli_available`, `cli_path`,
`opensim_version`, `simbody_version`, and `backend` (the backend that
would be used by default: `"native"`, `"cli"`, or `"none"`).

## Examples

``` r
opensimDiagnostics()
#> <PhysioOpenSim diagnostics>
#>   default backend  : none
#>   native available : FALSE (detect method: none)
#>   CLI available    : FALSE
#>   OpenSim version  : unknown
#>   Simbody version  : unknown
```
