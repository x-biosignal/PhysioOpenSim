# PhysioOpenSim

**Native OpenSim C++ Integration for PhysioExperiment**

PhysioOpenSim provides direct access to the OpenSim musculoskeletal
modeling library from R via Rcpp, without requiring Python or Java
bridges. The package wraps model-level operations and simulation tool
execution for seamless integration into biomechanics analysis workflows
within the
[PhysioExperiment](https://github.com/x-biosignal/PhysioExperiment)
ecosystem.

OpenSim linkage is **optional at build time**. When the OpenSim C++ SDK
is not detected, the package installs in fallback mode with informative
runtime messages, ensuring that dependent packages can still be loaded.

## Features

### Build-Time Detection

PhysioOpenSim automatically locates the OpenSim SDK at install time
using two strategies (checked in order):

1.  **pkg-config** – `pkg-config opensim`
2.  **OPENSIM_HOME** – environment variable pointing to the OpenSim
    installation root (inspects `include`/`sdk/include` and
    `lib`/`sdk/lib`)

If neither method succeeds, the package builds in **fallback mode**:
[`opensimAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimAvailable.md)
returns `FALSE` and OpenSim-dependent calls return a descriptive error.

### Availability Checks

| Function | Description |
|----|----|
| [`opensimAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimAvailable.md) | Whether the native C++ backend was linked at build time |
| [`opensimBuildConfig()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimBuildConfig.md) | Detection method, include/lib paths, and build flags |
| [`opensimCLIAvailable()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIAvailable.md) | Whether the `opensim-cmd` command-line tool is on `PATH` |
| [`opensimCLIPath()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimCLIPath.md) | Full path to the `opensim-cmd` executable |

### Model Operations

| Function | Description |
|----|----|
| [`opensimLoadModel()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimLoadModel.md) | Load an `.osim` model file into memory |
| [`opensimSaveModel()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimSaveModel.md) | Save a model back to an `.osim` file |
| [`opensimModelName()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelName.md) | Get the model name |
| [`opensimSetModelName()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimSetModelName.md) | Set the model name |
| [`opensimModelSummary()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelSummary.md) | Bodies, joints, muscles, markers, forces summary |
| [`opensimModelComponents()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelComponents.md) | List all component paths in the model |
| [`opensimModelInitialize()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelInitialize.md) | Initialize the model system |
| [`opensimModelIsInitialized()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimModelIsInitialized.md) | Check initialization status |
| [`opensimFinalizeConnections()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimFinalizeConnections.md) | Finalize model connections before simulation |

### Tool Execution

Each tool wrapper supports three execution backends selected by the
`execution` argument:

- **`"native"`** – calls the OpenSim C++ API directly (requires a
  native-enabled build)
- **`"cli"`** – invokes `opensim-cmd run-tool` as a subprocess
- **`"auto"`** (default) – uses native when available, otherwise falls
  back to CLI

All wrappers return a structured list containing `execution` backend
used, `stdout`, `stderr`, exit `status`, and `elapsed` time for pipeline
logging and reproducibility.

| Function | Description |
|----|----|
| [`opensimRunTool()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunTool.md) | Execute any OpenSim tool from a setup XML |
| [`opensimRunIK()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunIK.md) | Inverse Kinematics |
| [`opensimRunID()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunID.md) | Inverse Dynamics |
| [`opensimRunSO()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunSO.md) | Static Optimization |
| [`opensimRunAnalyze()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunAnalyze.md) | Analyze tool |
| [`opensimRunCMC()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunCMC.md) | Computed Muscle Control |
| [`opensimRunRRA()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimRunRRA.md) | Residual Reduction Algorithm |

### Setup XML Generation

Use existing OpenSim-generated setup XMLs as templates and
programmatically replace tags from R. This enables batch processing of
multiple trials without manual XML editing.

| Function | Description |
|----|----|
| [`opensimWriteToolSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteToolSetupFromTemplate.md) | Generic XML tag replacement |
| [`opensimWriteIKSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIKSetupFromTemplate.md) | Inverse Kinematics setup |
| [`opensimWriteIDSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteIDSetupFromTemplate.md) | Inverse Dynamics setup |
| [`opensimWriteSOSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteSOSetupFromTemplate.md) | Static Optimization setup |
| [`opensimWriteAnalyzeSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteAnalyzeSetupFromTemplate.md) | Analyze tool setup |
| [`opensimWriteRRASetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteRRASetupFromTemplate.md) | RRA setup |
| [`opensimWriteCMCSetupFromTemplate()`](https://x-biosignal.github.io/PhysioOpenSim/reference/opensimWriteCMCSetupFromTemplate.md) | CMC setup |

## Installation

### From R-universe

``` r

install.packages("PhysioOpenSim",
                  repos = c("https://x-biosignal.r-universe.dev",
                            "https://cloud.r-project.org"))
```

### From GitHub

``` r

# install.packages("remotes")
remotes::install_github("x-biosignal/PhysioOpenSim")
```

### OpenSim-Enabled Build

To link against the OpenSim C++ SDK, make the SDK discoverable before
installing:

**Using pkg-config (Linux / macOS):**

``` bash
export PKG_CONFIG_PATH="/path/to/opensim/lib/pkgconfig:${PKG_CONFIG_PATH}"
R CMD INSTALL PhysioOpenSim
```

**Using OPENSIM_HOME (Linux / macOS / Windows):**

``` bash
export OPENSIM_HOME="/path/to/opensim"
R CMD INSTALL PhysioOpenSim
```

The package requires **C++17** and **R \>= 4.2**.

## Quick Start

``` r

library(PhysioOpenSim)

# --- Check availability ---
opensimAvailable()
#> [1] TRUE
opensimBuildConfig()
#> $detect_method
#> [1] "OPENSIM_HOME"
#> $include_path
#> [1] "/opt/opensim/sdk/include"
#> ...

# --- Load and inspect a model ---
model <- opensimLoadModel("gait2392.osim")
opensimModelName(model)
#> [1] "gait2392"
opensimModelSummary(model)
#> Bodies: 13, Joints: 13, Muscles: 92, Markers: 35

# --- Initialize for simulation ---
opensimModelInitialize(model)
opensimFinalizeConnections(model)

# --- Batch-process IK from a template ---
ik_setup <- opensimWriteIKSetupFromTemplate(
  template_file = "templates/ik_setup.xml",
  output_file   = "run/trial01_ik_setup.xml",
  model_file    = "model/gait2392.osim",
  marker_file   = "data/trial01.trc",
  output_motion_file = "results/trial01_ik.mot",
  time_range    = c(0.5, 1.5)
)

# --- Run Inverse Kinematics ---
result <- opensimRunIK(ik_setup$output_file, fail_on_error = FALSE)
result$execution
#> [1] "native"
result$status
#> [1] 0
result$elapsed
#> [1] 2.34

# --- Backend selection ---
result_cli <- opensimRunIK("setup_ik.xml", execution = "cli")
result_nat <- opensimRunIK("setup_ik.xml", execution = "native")
```

## Dependencies

- **R** (\>= 4.2)
- **Rcpp** (linked)
- **OpenSim C++ SDK** (optional; graceful fallback when unavailable)

## Ecosystem

PhysioOpenSim is part of the [PhysioExperiment
ecosystem](https://github.com/x-biosignal/PhysioExperiment), a suite of
R packages for multi-modal physiological signal analysis.

Related packages:

| Package | Role |
|----|----|
| [PhysioExperiment](https://github.com/x-biosignal/PhysioExperiment) | Core data model and signal processing |
| [PhysioMoCap](https://github.com/x-biosignal/PhysioExperiment) | Motion capture I/O and analysis |
| [PhysioMSKNet](https://github.com/x-biosignal/PhysioExperiment) | Musculoskeletal network analysis |
| [PhysioAnnotationHub](https://github.com/x-biosignal/PhysioExperiment) | Anatomical knowledge graph |

## Author

Yusuke Matsui

## License

MIT

## Governance & support

Part of the [Physio ecosystem](https://x-biosignal.r-universe.dev).
Community and policy documents live in the umbrella repository:

- [Code of
  Conduct](https://github.com/x-biosignal/PhysioExperiment/blob/main/CODE_OF_CONDUCT.md)
- [Contributing](https://github.com/x-biosignal/PhysioExperiment/blob/main/CONTRIBUTING.md)
- [Governance](https://github.com/x-biosignal/PhysioExperiment/blob/main/GOVERNANCE.md)
- [Support](https://github.com/x-biosignal/PhysioExperiment/blob/main/SUPPORT.md)
- [Security
  policy](https://github.com/x-biosignal/PhysioExperiment/blob/main/SECURITY.md)
- [Deprecation & lifecycle
  policy](https://github.com/x-biosignal/PhysioExperiment/blob/main/DEPRECATION.md)
