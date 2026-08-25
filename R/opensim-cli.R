#' Resolve OpenSim CLI Command Path
#'
#' Resolves the command path used to invoke OpenSim CLI.
#'
#' @param cli Optional command or absolute path. Defaults to `OPENSIM_CLI`
#'   environment variable, then `"opensim-cmd"`.
#' @return A character scalar path to executable command.
#' @export
#' @examples
#' \dontrun{
#' opensimCLIPath()
#' opensimCLIPath("/usr/local/bin/opensim-cmd")
#' }
opensimCLIPath <- function(cli = NULL) {
  cmd <- cli
  if (is.null(cmd) || !nzchar(cmd)) {
    cmd <- Sys.getenv("OPENSIM_CLI", unset = "opensim-cmd")
  }

  if (!is.character(cmd) || length(cmd) != 1L || is.na(cmd) || !nzchar(cmd)) {
    stop("`cli` must be a non-empty character scalar.", call. = FALSE)
  }

  has_sep <- grepl("[/\\\\]", cmd)
  if (has_sep) {
    if (!file.exists(cmd)) {
      stop("OpenSim CLI executable does not exist: ", cmd, call. = FALSE)
    }
    return(normalizePath(cmd, winslash = "/", mustWork = TRUE))
  }

  resolved <- Sys.which(cmd)
  if (!nzchar(resolved)) {
    stop(
      "OpenSim CLI command not found: '", cmd, "'. ",
      "Install OpenSim CLI or set OPENSIM_CLI to executable path.",
      call. = FALSE
    )
  }
  unname(resolved)
}

#' Check Whether OpenSim CLI Is Available
#'
#' @param cli Optional command or absolute path.
#' @return `TRUE` if CLI command is resolvable, otherwise `FALSE`.
#' @export
#' @examples
#' opensimCLIAvailable()
opensimCLIAvailable <- function(cli = NULL) {
  isTRUE(tryCatch({
    opensimCLIPath(cli)
    TRUE
  }, error = function(e) FALSE))
}

#' Run an OpenSim Tool Setup XML
#'
#' Executes a setup XML through native OpenSim bindings (when available) or
#' through OpenSim CLI.
#'
#' @param setup_file Path to OpenSim tool setup XML.
#' @param workdir Optional working directory.
#' @param cli Optional command or absolute path (CLI mode only).
#' @param extra_args Optional extra CLI args appended after setup file.
#' @param timeout_sec Timeout in seconds for CLI execution (0 disables timeout).
#' @param fail_on_error If `TRUE`, stop on non-zero exit status.
#' @param execution Execution backend: `"auto"` (default), `"native"`, `"cli"`.
#' @param tool_type Tool flavor token: `"tool"` (generic), `"ik"`, `"id"`, or
#'   `"so"`, `"analyze"`, `"cmc"`, `"rra"`.
#' @return A named list with command metadata and logs.
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunTool("ik_setup.xml")
#' result$status
#' result$stdout
#'
#' # Force CLI backend with extra arguments
#' opensimRunTool("ik_setup.xml", execution = "cli",
#'                extra_args = "--visualize")
#' }
opensimRunTool <- function(setup_file,
                           workdir = NULL,
                           cli = NULL,
                           extra_args = character(),
                           timeout_sec = 0L,
                           fail_on_error = TRUE,
                           execution = c("auto", "native", "cli"),
                           tool_type = c("tool", "ik", "id", "so", "analyze", "cmc", "rra")) {
  execution <- match.arg(execution)
  tool_type <- match.arg(tool_type)

  setup_path <- .opensim_validate_setup_file(setup_file)
  .opensim_validate_workdir(workdir)
  .opensim_validate_extra_args(extra_args)
  .opensim_validate_timeout(timeout_sec)
  .opensim_validate_fail_on_error(fail_on_error)

  use_native <- FALSE
  if (execution == "native") {
    use_native <- TRUE
  } else if (execution == "auto") {
    use_native <- isTRUE(opensimAvailable()) &&
      !identical(tool_type, "tool") &&
      length(extra_args) == 0L
  }

  if (use_native && identical(tool_type, "tool")) {
    stop("Native backend requires tool_type to be one of: ik, id, so, analyze, cmc, rra.", call. = FALSE)
  }
  if (use_native && length(extra_args) > 0L) {
    stop("`extra_args` is only supported for CLI execution.", call. = FALSE)
  }
  if (identical(execution, "native") && !isTRUE(opensimAvailable())) {
    stop(
      "Requested native execution, but package was compiled without OpenSim support.",
      call. = FALSE
    )
  }

  if (use_native) {
    native_result <- tryCatch(
      .opensim_run_tool_native(
        setup_path = setup_path,
        tool_type = tool_type,
        workdir = workdir,
        fail_on_error = fail_on_error
      ),
      error = function(e) e
    )
    if (!inherits(native_result, "condition")) {
      return(native_result)
    }
    # In "auto" mode a native run that errors falls back to the CLI when one is
    # available; an explicit execution = "native" request is not silently
    # rerouted.
    if (!identical(execution, "auto") || !isTRUE(opensimCLIAvailable(cli))) {
      stop(native_result)
    }
    warning(
      "Native OpenSim execution failed (", conditionMessage(native_result),
      "); falling back to the opensim-cmd CLI.",
      call. = FALSE
    )
  }

  .opensim_run_tool_cli(
    setup_path = setup_path,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error
  )
}

#' Run OpenSim Inverse Kinematics Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunIK("ik_setup.xml")
#' result$status
#' }
opensimRunIK <- function(setup_file,
                         workdir = NULL,
                         cli = NULL,
                         extra_args = character(),
                         timeout_sec = 0L,
                         fail_on_error = TRUE,
                         execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "ik"
  )
}

#' Run OpenSim Inverse Dynamics Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunID("id_setup.xml")
#' result$status
#' }
opensimRunID <- function(setup_file,
                         workdir = NULL,
                         cli = NULL,
                         extra_args = character(),
                         timeout_sec = 0L,
                         fail_on_error = TRUE,
                         execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "id"
  )
}

#' Run OpenSim Static Optimization Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunSO("so_setup.xml")
#' result$status
#' }
opensimRunSO <- function(setup_file,
                         workdir = NULL,
                         cli = NULL,
                         extra_args = character(),
                         timeout_sec = 0L,
                         fail_on_error = TRUE,
                         execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "so"
  )
}

#' Run OpenSim Analyze Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunAnalyze("analyze_setup.xml")
#' result$status
#' }
opensimRunAnalyze <- function(setup_file,
                              workdir = NULL,
                              cli = NULL,
                              extra_args = character(),
                              timeout_sec = 0L,
                              fail_on_error = TRUE,
                              execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "analyze"
  )
}

#' Run OpenSim Computed Muscle Control Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunCMC("cmc_setup.xml")
#' result$status
#' }
opensimRunCMC <- function(setup_file,
                          workdir = NULL,
                          cli = NULL,
                          extra_args = character(),
                          timeout_sec = 0L,
                          fail_on_error = TRUE,
                          execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "cmc"
  )
}

#' Run OpenSim Residual Reduction Algorithm Tool
#'
#' @inheritParams opensimRunTool
#' @return See [opensimRunTool()].
#' @export
#' @examples
#' \dontrun{
#' result <- opensimRunRRA("rra_setup.xml")
#' result$status
#' }
opensimRunRRA <- function(setup_file,
                          workdir = NULL,
                          cli = NULL,
                          extra_args = character(),
                          timeout_sec = 0L,
                          fail_on_error = TRUE,
                          execution = c("auto", "native", "cli")) {
  opensimRunTool(
    setup_file = setup_file,
    workdir = workdir,
    cli = cli,
    extra_args = extra_args,
    timeout_sec = timeout_sec,
    fail_on_error = fail_on_error,
    execution = match.arg(execution),
    tool_type = "rra"
  )
}

#' @keywords internal
.opensim_run_tool_native <- function(setup_path, tool_type, workdir, fail_on_error) {
  old_wd <- NULL
  if (!is.null(workdir)) {
    old_wd <- getwd()
    setwd(workdir)
    on.exit(setwd(old_wd), add = TRUE)
  }

  t0 <- proc.time()[["elapsed"]]
  native <- cpp_opensim_run_tool_native(setup_path, tool_type)
  t1 <- proc.time()[["elapsed"]]

  status_num <- as.integer(native$status)
  out_lines <- as.character(native$stdout)
  err_lines <- as.character(native$stderr)

  result <- list(
    execution = "native",
    command = paste0("native:", tool_type),
    args = character(),
    setup_file = setup_path,
    workdir = if (is.null(workdir)) getwd() else normalizePath(workdir, winslash = "/", mustWork = TRUE),
    status = status_num,
    stdout = out_lines,
    stderr = err_lines,
    elapsed_sec = unname(as.numeric(t1 - t0))
  )

  if (isTRUE(fail_on_error) && !identical(status_num, 0L)) {
    msg <- paste0(
      "OpenSim native tool execution failed with status ", status_num, ".",
      if (length(err_lines) > 0) paste0(" stderr: ", paste(utils::head(err_lines, 10L), collapse = " | ")) else ""
    )
    stop(msg, call. = FALSE)
  }

  result
}

#' @keywords internal
.opensim_run_tool_cli <- function(setup_path, workdir, cli, extra_args, timeout_sec, fail_on_error) {
  cmd <- opensimCLIPath(cli)
  args <- c("run-tool", setup_path, extra_args)

  out_file <- tempfile("physioopensim_stdout_")
  err_file <- tempfile("physioopensim_stderr_")
  on.exit(unlink(c(out_file, err_file), force = TRUE), add = TRUE)

  old_wd <- NULL
  if (!is.null(workdir)) {
    old_wd <- getwd()
    setwd(workdir)
    on.exit(setwd(old_wd), add = TRUE)
  }

  t0 <- proc.time()[["elapsed"]]
  status <- suppressWarnings(system2(
    command = cmd,
    args = args,
    stdout = out_file,
    stderr = err_file,
    wait = TRUE,
    timeout = as.integer(timeout_sec)
  ))
  t1 <- proc.time()[["elapsed"]]

  out_lines <- if (file.exists(out_file)) readLines(out_file, warn = FALSE) else character()
  err_lines <- if (file.exists(err_file)) readLines(err_file, warn = FALSE) else character()
  status_num <- if (is.null(status)) 0L else as.integer(status)

  result <- list(
    execution = "cli",
    command = cmd,
    args = args,
    setup_file = setup_path,
    workdir = if (is.null(workdir)) getwd() else normalizePath(workdir, winslash = "/", mustWork = TRUE),
    status = status_num,
    stdout = out_lines,
    stderr = err_lines,
    elapsed_sec = unname(as.numeric(t1 - t0))
  )

  if (isTRUE(fail_on_error) && !identical(status_num, 0L)) {
    msg <- paste0(
      "OpenSim tool execution failed with status ", status_num, ".",
      if (length(err_lines) > 0) paste0(" stderr: ", paste(utils::head(err_lines, 10L), collapse = " | ")) else ""
    )
    stop(msg, call. = FALSE)
  }

  result
}

#' @keywords internal
.opensim_validate_setup_file <- function(setup_file) {
  if (!is.character(setup_file) || length(setup_file) != 1L || is.na(setup_file) || !nzchar(setup_file)) {
    stop("`setup_file` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!file.exists(setup_file)) {
    stop("OpenSim setup file does not exist: ", setup_file, call. = FALSE)
  }
  normalizePath(setup_file, winslash = "/", mustWork = TRUE)
}

#' @keywords internal
.opensim_validate_workdir <- function(workdir) {
  if (is.null(workdir)) return(invisible(NULL))
  if (!is.character(workdir) || length(workdir) != 1L || is.na(workdir) || !nzchar(workdir)) {
    stop("`workdir` must be NULL or a non-empty character scalar.", call. = FALSE)
  }
  if (!dir.exists(workdir)) {
    stop("`workdir` does not exist: ", workdir, call. = FALSE)
  }
  invisible(NULL)
}

#' @keywords internal
.opensim_validate_extra_args <- function(extra_args) {
  if (!is.character(extra_args)) {
    stop("`extra_args` must be a character vector.", call. = FALSE)
  }
  invisible(NULL)
}

#' @keywords internal
.opensim_validate_timeout <- function(timeout_sec) {
  if (!is.numeric(timeout_sec) || length(timeout_sec) != 1L || is.na(timeout_sec) || timeout_sec < 0) {
    stop("`timeout_sec` must be a non-negative numeric scalar.", call. = FALSE)
  }
  invisible(NULL)
}

#' @keywords internal
.opensim_validate_fail_on_error <- function(fail_on_error) {
  if (!is.logical(fail_on_error) || length(fail_on_error) != 1L || is.na(fail_on_error)) {
    stop("`fail_on_error` must be a non-missing logical scalar.", call. = FALSE)
  }
  invisible(NULL)
}
