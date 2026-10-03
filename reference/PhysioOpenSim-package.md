# PhysioOpenSim: Native OpenSim C++ Integration for PhysioExperiment

PhysioOpenSim drives the OpenSim musculoskeletal modelling library from
R through an Rcpp bridge, with no Python or Java layer in between. It
loads and inspects `.osim` models, runs the standard OpenSim simulation
tools (inverse kinematics, inverse dynamics, static optimization, and
more), and generates tool setup XML from templates for batch processing.
The native C++ link is optional: when the OpenSim SDK is not detected at
build time the package still installs,
[`opensimAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimAvailable.md)
returns `FALSE`, and OpenSim-dependent calls raise an informative error
or fall back to the `opensim-cmd` command-line tool.

## Availability and diagnostics

Start here to learn what your build can do.

- [`opensimAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimAvailable.md)
  – was the native C++ backend linked?

- [`opensimBuildConfig()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimBuildConfig.md)
  – detection method, include/lib paths, flags.

- [`opensimCLIAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIAvailable.md),
  [`opensimCLIPath()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIPath.md)
  – is `opensim-cmd` on `PATH`?

- [`opensimDiagnostics()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimDiagnostics.md)
  – a single summary of native and CLI readiness.

## Model operations

Load, inspect, modify, and save models.

- [`opensimLoadModel()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimLoadModel.md),
  [`opensimSaveModel()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimSaveModel.md)

- [`opensimModelName()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelName.md),
  [`opensimSetModelName()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimSetModelName.md)

- [`opensimModelSummary()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelSummary.md),
  [`opensimModelComponents()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelComponents.md)

- [`opensimModelInitialize()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelInitialize.md),
  [`opensimModelIsInitialized()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelIsInitialized.md),
  [`opensimFinalizeConnections()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimFinalizeConnections.md)

## Tool execution

Each wrapper takes a setup XML and an `execution` backend (`"native"`,
`"cli"`, or `"auto"`) and returns a structured result list (backend
used, stdout, stderr, status, elapsed).

- [`opensimRunTool()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunTool.md)
  – run any tool from a setup XML.

- [`opensimRunIK()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunIK.md),
  [`opensimRunID()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunID.md),
  [`opensimRunSO()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunSO.md)

- [`opensimRunAnalyze()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunAnalyze.md),
  [`opensimRunCMC()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunCMC.md),
  [`opensimRunRRA()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunRRA.md)

## Setup XML generation

Turn an existing OpenSim setup XML into a template and substitute fields
from R, so many trials can be processed without hand-editing XML.

- [`opensimTemplatePath()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimTemplatePath.md)
  – path to a bundled starter template.

- [`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md)
  – generic tag replacement.

- [`opensimWriteIKSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIKSetupFromTemplate.md),
  [`opensimWriteIDSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIDSetupFromTemplate.md),
  [`opensimWriteSOSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteSOSetupFromTemplate.md),
  [`opensimWriteAnalyzeSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteAnalyzeSetupFromTemplate.md),
  [`opensimWriteCMCSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteCMCSetupFromTemplate.md),
  [`opensimWriteRRASetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteRRASetupFromTemplate.md)

## Where to go next

See
[`vignette("getting-started", package = "PhysioOpenSim")`](https://x-biosignal.github.io/PhysioOpenSim/articles/getting-started.md)
for build detection and model loading, and
[`vignette("opensim-tool-pipeline", package = "PhysioOpenSim")`](https://x-biosignal.github.io/PhysioOpenSim/articles/opensim-tool-pipeline.md)
for a template-driven tool run. PhysioOpenSim is part of the
PhysioExperiment ecosystem; marker and motion data usually come from
PhysioMoCap, and downstream musculoskeletal network analysis lives in
PhysioMSKNet.

## See also

Useful links:

- <https://github.com/x-biosignal/PhysioOpenSim>

- <https://x-biosignal.r-universe.dev/PhysioOpenSim>

- <https://x-biosignal.github.io/PhysioOpenSim/>

- Report bugs at <https://github.com/x-biosignal/PhysioOpenSim/issues>

## Author

**Maintainer**: Yusuke Matsui <matsui.yusuke.bioinfo@gmail.com>
