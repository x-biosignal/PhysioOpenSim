#' Check Whether Native OpenSim Support Is Available
#'
#' Returns whether this package was compiled with OpenSim headers and
#' libraries linked into the native code.
#'
#' @return `TRUE` if OpenSim native support is available, otherwise `FALSE`.
#' @export
#' @examples
#' opensimAvailable()
opensimAvailable <- function() {
  cpp_opensim_compiled()
}

#' Show Build Configuration for OpenSim Native Bridge
#'
#' @return A list containing compilation status and build metadata.
#' @export
#' @examples
#' cfg <- opensimBuildConfig()
#' cfg$package
#' cfg$opensim_enabled
opensimBuildConfig <- function() {
  cfg <- cpp_opensim_build_config()
  list(
    package = "PhysioOpenSim",
    opensim_enabled = isTRUE(cfg$opensim_enabled),
    detect_method = as.character(cfg$detect_method)
  )
}

#' Report the OpenSim Integration Environment
#'
#' Collects a single diagnostic snapshot of how this package can reach OpenSim:
#' whether the native bridge was compiled in and by which detection method,
#' whether the `opensim-cmd` CLI is on the search path, and the OpenSim / Simbody
#' versions reported by whichever backend is available. Useful in CI logs and
#' bug reports.
#'
#' @param cli Optional `opensim-cmd` command or path passed to
#'   [opensimCLIAvailable()] / [opensimCLIPath()].
#' @return An `opensim_diagnostics` list with elements `package`,
#'   `native_available`, `detect_method`, `cli_available`, `cli_path`,
#'   `opensim_version`, `simbody_version`, and `backend` (the backend that would
#'   be used by default: `"native"`, `"cli"`, or `"none"`).
#' @export
#' @examples
#' opensimDiagnostics()
opensimDiagnostics <- function(cli = NULL) {
  cfg <- opensimBuildConfig()
  native <- isTRUE(cfg$opensim_enabled)

  cli_ok <- opensimCLIAvailable(cli)
  cli_path <- if (cli_ok) {
    tryCatch(opensimCLIPath(cli), error = function(e) NA_character_)
  } else {
    NA_character_
  }

  ver <- cpp_opensim_version()
  opensim_version <- if (native && nzchar(ver$opensim)) {
    as.character(ver$opensim)
  } else if (cli_ok) {
    .opensim_cli_version(cli)
  } else {
    NA_character_
  }
  simbody_version <- if (native && nzchar(ver$simbody)) {
    as.character(ver$simbody)
  } else {
    NA_character_
  }

  backend <- if (native) "native" else if (cli_ok) "cli" else "none"

  out <- list(
    package = "PhysioOpenSim",
    native_available = native,
    detect_method = cfg$detect_method,
    cli_available = cli_ok,
    cli_path = cli_path,
    opensim_version = opensim_version,
    simbody_version = simbody_version,
    backend = backend
  )
  class(out) <- "opensim_diagnostics"
  out
}

#' Parse the OpenSim version reported by `opensim-cmd --version`
#' @keywords internal
#' @noRd
.opensim_cli_version <- function(cli = NULL) {
  tryCatch({
    cmd <- opensimCLIPath(cli)
    out <- suppressWarnings(system2(cmd, "--version", stdout = TRUE,
                                    stderr = TRUE))
    out <- trimws(paste(out, collapse = " "))
    if (nzchar(out)) out else NA_character_
  }, error = function(e) NA_character_)
}

#' @export
print.opensim_diagnostics <- function(x, ...) {
  cat("<PhysioOpenSim diagnostics>\n")
  cat(sprintf("  default backend  : %s\n", x$backend))
  cat(sprintf("  native available : %s (detect method: %s)\n",
              x$native_available, x$detect_method))
  cat(sprintf("  CLI available    : %s%s\n", x$cli_available,
              if (isTRUE(x$cli_available) && !is.na(x$cli_path)) {
                paste0(" (", x$cli_path, ")")
              } else {
                ""
              }))
  cat(sprintf("  OpenSim version  : %s\n",
              if (is.na(x$opensim_version)) "unknown" else x$opensim_version))
  cat(sprintf("  Simbody version  : %s\n",
              if (is.na(x$simbody_version)) "unknown" else x$simbody_version))
  invisible(x)
}

#' Load an OpenSim Model as a Native External Pointer
#'
#' @param path Path to an OpenSim model file (`.osim`).
#' @return A `PhysioOpenSimModel` external pointer handle.
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimModelName(model)
#' }
opensimLoadModel <- function(path) {
  model_path <- .opensim_non_empty_path(path, "path")
  ptr <- cpp_opensim_model_load(model_path)
  class(ptr) <- c("PhysioOpenSimModel", "externalptr")
  ptr
}

#' Check Whether an OpenSim Model Handle Is Initialized
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @return `TRUE` when model state has been initialized by OpenSim.
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimModelIsInitialized(model)
#' }
opensimModelIsInitialized <- function(model) {
  cpp_opensim_model_is_initialized(.opensim_assert_model_ptr(model))
}

#' Initialize OpenSim Model System State
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @return The input `model` handle (invisibly).
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimModelInitialize(model)
#' opensimModelIsInitialized(model)  # TRUE
#' }
opensimModelInitialize <- function(model) {
  ptr <- .opensim_assert_model_ptr(model)
  cpp_opensim_model_init(ptr)
  invisible(model)
}

#' Summarize an OpenSim Model via Native C++ API
#'
#' Loads an `.osim` model (or uses a loaded model handle) and returns
#' structural summary information.
#'
#' @param path Path to an OpenSim model file (`.osim`) or a
#'   `PhysioOpenSimModel` external pointer.
#' @return A named list with model metadata (`model_name`, `n_bodies`,
#'   `n_joints`, `n_markers`, `n_muscles`, `n_coordinates`, `total_mass`,
#'   `initialized`).
#' @export
#' @examples
#' \dontrun{
#' info <- opensimModelSummary("gait2392.osim")
#' info$model_name
#' info$n_muscles
#'
#' # Also works with a loaded model handle
#' model <- opensimLoadModel("gait2392.osim")
#' opensimModelSummary(model)
#' }
opensimModelSummary <- function(path) {
  if (inherits(path, "PhysioOpenSimModel")) {
    return(cpp_opensim_model_summary_ptr(.opensim_assert_model_ptr(path)))
  }

  model_path <- .opensim_non_empty_path(path, "path")
  cpp_opensim_model_summary(model_path)
}

#' List Core OpenSim Model Component Names
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @return Named list with vectors for body, joint, marker, muscle, and
#'   coordinate names.
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' comps <- opensimModelComponents(model)
#' comps$bodies
#' comps$muscles
#' }
opensimModelComponents <- function(model) {
  cpp_opensim_model_components(.opensim_assert_model_ptr(model))
}

#' Get OpenSim Model Name
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @return Character scalar model name.
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimModelName(model)
#' }
opensimModelName <- function(model) {
  cpp_opensim_model_get_name(.opensim_assert_model_ptr(model))
}

#' Set OpenSim Model Name
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @param name New model name.
#' @return The input `model` handle (invisibly).
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimSetModelName(model, "my_model")
#' opensimModelName(model)  # "my_model"
#' }
opensimSetModelName <- function(model, name) {
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)) {
    stop("`name` must be a non-empty character scalar.", call. = FALSE)
  }
  cpp_opensim_model_set_name(.opensim_assert_model_ptr(model), name)
  invisible(model)
}

#' Finalize OpenSim Model Connections
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @return The input `model` handle (invisibly).
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimFinalizeConnections(model)
#' }
opensimFinalizeConnections <- function(model) {
  cpp_opensim_model_finalize_connections(.opensim_assert_model_ptr(model))
  invisible(model)
}

#' Save OpenSim Model to File
#'
#' @param model A `PhysioOpenSimModel` external pointer.
#' @param output_file Output path for model XML.
#' @return Normalized output path.
#' @export
#' @examples
#' \dontrun{
#' model <- opensimLoadModel("gait2392.osim")
#' opensimSetModelName(model, "modified")
#' opensimSaveModel(model, "gait2392_modified.osim")
#' }
opensimSaveModel <- function(model, output_file) {
  ptr <- .opensim_assert_model_ptr(model)
  out <- .opensim_non_empty_path(output_file, "output_file", must_exist = FALSE)
  cpp_opensim_model_save(ptr, out)
  normalizePath(out, winslash = "/", mustWork = TRUE)
}

#' @keywords internal
.opensim_assert_model_ptr <- function(model) {
  if (!inherits(model, "PhysioOpenSimModel") || typeof(model) != "externalptr") {
    stop("`model` must be a PhysioOpenSimModel external pointer.", call. = FALSE)
  }
  model
}

#' @keywords internal
.opensim_non_empty_path <- function(path, arg, must_exist = TRUE) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`", arg, "` must be a non-empty character scalar.", call. = FALSE)
  }
  normalizePath(path, winslash = "/", mustWork = isTRUE(must_exist))
}
