# PhysioOpenSim

<!-- badges: start -->
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R-universe](https://x-biosignal.r-universe.dev/badges/PhysioOpenSim)](https://x-biosignal.r-universe.dev/PhysioOpenSim)
<!-- badges: end -->

**Native OpenSim C++ Integration for PhysioExperiment**

PhysioOpenSim provides direct access to the OpenSim musculoskeletal modeling
library from R via Rcpp, without requiring Python or Java bridges. The package
wraps model-level operations and simulation tool execution for seamless
integration into biomechanics analysis workflows within the
[PhysioExperiment](https://github.com/x-biosignal/PhysioExperiment) ecosystem.

OpenSim linkage is **optional at build time**. When the OpenSim C++ SDK is not
detected, the package installs in fallback mode with informative runtime
messages, ensuring that dependent packages can still be loaded.

## Features

### Build-Time Detection

PhysioOpenSim automatically locates the OpenSim SDK at install time using two
strategies (checked in order):

1. **pkg-config** -- `pkg-config opensim`
2. **OPENSIM_HOME** -- environment variable pointing to the OpenSim
   installation root (inspects `include`/`sdk/include` and `lib`/`sdk/lib`)

If neither method succeeds, the package builds in **fallback mode**:
`opensimAvailable()` returns `FALSE` and OpenSim-dependent calls return a
descriptive error.

### Availability Checks

| Function | Description |
|---|---|
| `opensimAvailable()` | Whether the native C++ backend was linked at build time |
| `opensimBuildConfig()` | Detection method, include/lib paths, and build flags |
| `opensimCLIAvailable()` | Whether the `opensim-cmd` command-line tool is on `PATH` |
| `opensimCLIPath()` | Full path to the `opensim-cmd` executable |

### Model Operations

| Function | Description |
|---|---|
| `opensimLoadModel()` | Load an `.osim` model file into memory |
| `opensimSaveModel()` | Save a model back to an `.osim` file |
| `opensimModelName()` | Get the model name |
| `opensimSetModelName()` | Set the model name |
| `opensimModelSummary()` | Bodies, joints, muscles, markers, forces summary |
| `opensimModelComponents()` | List all component paths in the model |
| `opensimModelInitialize()` | Initialize the model system |
| `opensimModelIsInitialized()` | Check initialization status |
| `opensimFinalizeConnections()` | Finalize model connections before simulation |

### Tool Execution

Each tool wrapper supports three execution backends selected by the
`execution` argument:

- **`"native"`** -- calls the OpenSim C++ API directly (requires a
  native-enabled build)
- **`"cli"`** -- invokes `opensim-cmd run-tool` as a subprocess
- **`"auto"`** (default) -- uses native when available, otherwise falls back
  to CLI

All wrappers return a structured list containing `execution` backend used,
`stdout`, `stderr`, exit `status`, and `elapsed` time for pipeline logging and
reproducibility.

| Function | Description |
|---|---|
| `opensimRunTool()` | Execute any OpenSim tool from a setup XML |
| `opensimRunIK()` | Inverse Kinematics |
| `opensimRunID()` | Inverse Dynamics |
| `opensimRunSO()` | Static Optimization |
| `opensimRunAnalyze()` | Analyze tool |
| `opensimRunCMC()` | Computed Muscle Control |
| `opensimRunRRA()` | Residual Reduction Algorithm |

### Setup XML Generation

Use existing OpenSim-generated setup XMLs as templates and programmatically
replace tags from R. This enables batch processing of multiple trials without
manual XML editing.

| Function | Description |
|---|---|
| `opensimWriteToolSetupFromTemplate()` | Generic XML tag replacement |
| `opensimWriteIKSetupFromTemplate()` | Inverse Kinematics setup |
| `opensimWriteIDSetupFromTemplate()` | Inverse Dynamics setup |
| `opensimWriteSOSetupFromTemplate()` | Static Optimization setup |
| `opensimWriteAnalyzeSetupFromTemplate()` | Analyze tool setup |
| `opensimWriteRRASetupFromTemplate()` | RRA setup |
| `opensimWriteCMCSetupFromTemplate()` | CMC setup |

## Installation

### From R-universe

```r
# the containers build on Bioconductor, so its repositories are needed too
install.packages("BiocManager", repos = "https://cloud.r-project.org")
install.packages("PhysioOpenSim",
                  repos = c("https://x-biosignal.r-universe.dev", BiocManager::repositories()))
```

### From GitHub

```r
# install.packages("remotes", repos = "https://cloud.r-project.org")
remotes::install_github("x-biosignal/PhysioOpenSim")
```

### OpenSim-Enabled Build

To link against the OpenSim C++ SDK, make the SDK discoverable before
installing:

**Using pkg-config (Linux / macOS):**

```bash
export PKG_CONFIG_PATH="/path/to/opensim/lib/pkgconfig:${PKG_CONFIG_PATH}"
R CMD INSTALL PhysioOpenSim
```

**Using OPENSIM_HOME (Linux / macOS / Windows):**

```bash
export OPENSIM_HOME="/path/to/opensim"
R CMD INSTALL PhysioOpenSim
```

The package requires **C++17** and **R >= 4.2**.

## Quick Start

The native OpenSim backend is optional. The quick start below works **without**
it; the model-loading and tool-execution calls that need a native build are
shown in a separate, clearly-guarded block.

```r
library(PhysioOpenSim)

# --- Availability (native OpenSim is optional) ---
opensimAvailable()      # FALSE unless built against the OpenSim C++ SDK
opensimDiagnostics()    # backend, native/CLI availability, versions

# --- Locate the bundled OpenSim setup-XML templates ---
opensimTemplatePath("ik")
opensimTemplatePath("id")

# --- Fill a template to produce a ready-to-run setup XML (batch trial
#     preparation; works without a native OpenSim build) ---
setup <- opensimWriteToolSetupFromTemplate(
  template_file = opensimTemplatePath("generic"),
  output_file   = file.path(tempdir(), "trial01_setup.xml"),
  fields = list(
    model_file        = "model/subject01.osim",
    time_range        = "0.5 1.5",
    results_directory = "results/trial01"
  )
)
setup$applied_tags
readLines(setup$output_file)
```

Model operations and tool execution require a native-enabled build (see
"OpenSim-Enabled Build" above) plus your own `.osim` model and `.trc` markers.
The guard keeps the block inert on a fallback build:

```r
if (opensimAvailable()) {
  model <- opensimLoadModel("subject01.osim")
  opensimModelName(model)
  opensimModelSummary(model)

  ik_setup <- opensimWriteIKSetupFromTemplate(
    template_file = opensimTemplatePath("ik"),
    output_file   = file.path(tempdir(), "trial01_ik_setup.xml"),
    model_file    = "subject01.osim",
    marker_file   = "trial01.trc",
    output_motion_file = "trial01_ik.mot",
    time_range    = c(0.5, 1.5)
  )

  # execution = "auto" uses native when available, otherwise the opensim-cmd CLI
  result <- opensimRunIK(ik_setup$output_file, fail_on_error = FALSE)
  result$execution   # "native" or "cli"
  result$status
  result$elapsed
}
```

## Dependencies

- **R** (>= 4.2)
- **Rcpp** (linked)
- **OpenSim C++ SDK** (optional; graceful fallback when unavailable)

## Ecosystem

PhysioOpenSim is part of the
[PhysioExperiment ecosystem](https://github.com/x-biosignal/PhysioExperiment),
a suite of R packages for multi-modal physiological signal analysis.

Related packages:

| Package | Role |
|---|---|
| [PhysioExperiment](https://github.com/x-biosignal/PhysioExperiment) | Core data model and signal processing |
| [PhysioMoCap](https://github.com/x-biosignal/PhysioExperiment) | Motion capture I/O and analysis |
| [PhysioMSKNet](https://github.com/x-biosignal/PhysioExperiment) | Musculoskeletal network analysis |
| [PhysioAnnotationHub](https://github.com/x-biosignal/PhysioExperiment) | Anatomical knowledge graph |

## Author

Yusuke Matsui

## License

MIT

## Governance & support

Part of the [Physio ecosystem](https://x-biosignal.r-universe.dev). Community and
policy documents live in the umbrella repository:

- [Code of Conduct](https://github.com/x-biosignal/PhysioExperiment/blob/main/CODE_OF_CONDUCT.md)
- [Contributing](https://github.com/x-biosignal/PhysioExperiment/blob/main/CONTRIBUTING.md)
- [Governance](https://github.com/x-biosignal/PhysioExperiment/blob/main/GOVERNANCE.md)
- [Support](https://github.com/x-biosignal/PhysioExperiment/blob/main/SUPPORT.md)
- [Security policy](https://github.com/x-biosignal/PhysioExperiment/blob/main/SECURITY.md)
- [Deprecation & lifecycle policy](https://github.com/x-biosignal/PhysioExperiment/blob/main/DEPRECATION.md)
