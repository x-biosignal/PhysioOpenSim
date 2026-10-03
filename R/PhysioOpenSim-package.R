#' PhysioOpenSim: Native OpenSim C++ Integration for PhysioExperiment
#'
#' PhysioOpenSim drives the OpenSim musculoskeletal modelling library from R
#' through an Rcpp bridge, with no Python or Java layer in between. It loads and
#' inspects `.osim` models, runs the standard OpenSim simulation tools (inverse
#' kinematics, inverse dynamics, static optimization, and more), and generates
#' tool setup XML from templates for batch processing. The native C++ link is
#' optional: when the OpenSim SDK is not detected at build time the package
#' still installs, [opensimAvailable()] returns `FALSE`, and OpenSim-dependent
#' calls raise an informative error or fall back to the `opensim-cmd`
#' command-line tool.
#'
#' @section Availability and diagnostics:
#' Start here to learn what your build can do.
#'   * [opensimAvailable()] -- was the native C++ backend linked?
#'   * [opensimBuildConfig()] -- detection method, include/lib paths, flags.
#'   * [opensimCLIAvailable()], [opensimCLIPath()] -- is `opensim-cmd` on `PATH`?
#'   * [opensimDiagnostics()] -- a single summary of native and CLI readiness.
#'
#' @section Model operations:
#' Load, inspect, modify, and save models.
#'   * [opensimLoadModel()], [opensimSaveModel()]
#'   * [opensimModelName()], [opensimSetModelName()]
#'   * [opensimModelSummary()], [opensimModelComponents()]
#'   * [opensimModelInitialize()], [opensimModelIsInitialized()],
#'     [opensimFinalizeConnections()]
#'
#' @section Tool execution:
#' Each wrapper takes a setup XML and an `execution` backend
#' (`"native"`, `"cli"`, or `"auto"`) and returns a structured result list
#' (backend used, stdout, stderr, status, elapsed).
#'   * [opensimRunTool()] -- run any tool from a setup XML.
#'   * [opensimRunIK()], [opensimRunID()], [opensimRunSO()]
#'   * [opensimRunAnalyze()], [opensimRunCMC()], [opensimRunRRA()]
#'
#' @section Setup XML generation:
#' Turn an existing OpenSim setup XML into a template and substitute fields from
#' R, so many trials can be processed without hand-editing XML.
#'   * [opensimTemplatePath()] -- path to a bundled starter template.
#'   * [opensimWriteToolSetupFromTemplate()] -- generic tag replacement.
#'   * [opensimWriteIKSetupFromTemplate()], [opensimWriteIDSetupFromTemplate()],
#'     [opensimWriteSOSetupFromTemplate()],
#'     [opensimWriteAnalyzeSetupFromTemplate()],
#'     [opensimWriteCMCSetupFromTemplate()], [opensimWriteRRASetupFromTemplate()]
#'
#' @section Where to go next:
#' See `vignette("getting-started", package = "PhysioOpenSim")` for build
#' detection and model loading, and
#' `vignette("opensim-tool-pipeline", package = "PhysioOpenSim")` for a
#' template-driven tool run. PhysioOpenSim is part of the PhysioExperiment
#' ecosystem; marker and motion data usually come from \pkg{PhysioMoCap}, and
#' downstream musculoskeletal network analysis lives in \pkg{PhysioMSKNet}.
#'
#' @keywords internal
"_PACKAGE"
