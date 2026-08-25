# --- opensimRunTool input validation ---

test_that("opensimRunTool validates setup file path", {
  expect_error(
    opensimRunTool("this/setup/does/not/exist.xml"),
    "does not exist"
  )
})

test_that("opensimRunTool validates setup_file type", {
  expect_error(
    opensimRunTool(123),
    "non-empty character scalar"
  )
  expect_error(
    opensimRunTool(""),
    "non-empty character scalar"
  )
})

test_that("opensimRunTool validates workdir argument", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, workdir = "this/workdir/does/not/exist"),
    "workdir"
  )
})

test_that("opensimRunTool validates extra_args type", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, extra_args = 123),
    "character vector"
  )
})

test_that("opensimRunTool validates timeout_sec", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, timeout_sec = -1),
    "non-negative"
  )
  expect_error(
    opensimRunTool(tmp, timeout_sec = "abc"),
    "non-negative"
  )
})

test_that("opensimRunTool validates fail_on_error", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, fail_on_error = NA),
    "non-missing logical"
  )
  expect_error(
    opensimRunTool(tmp, fail_on_error = "yes"),
    "non-missing logical"
  )
})

# --- Native backend restrictions ---

test_that("opensimRunTool rejects generic native tool token", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, execution = "native", tool_type = "tool"),
    "requires tool_type to be one of"
  )
})

test_that("opensimRunTool rejects extra_args with native execution", {
  skip_if(!opensimAvailable(), "Native OpenSim required")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunTool(tmp, execution = "native", tool_type = "ik",
                   extra_args = c("--flag")),
    "extra_args.*only supported for CLI"
  )
})

# --- Fallback errors for typed wrappers ---

test_that("opensimRunIK native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build; this test targets fallback behavior")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunIK(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

test_that("opensimRunID native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunID(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

test_that("opensimRunSO native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunSO(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

test_that("opensimRunAnalyze native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunAnalyze(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

test_that("opensimRunCMC native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunCMC(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

test_that("opensimRunRRA native mode errors if native support is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")

  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  expect_error(
    opensimRunRRA(tmp, execution = "native"),
    "compiled without OpenSim support"
  )
})

# --- native -> CLI fallback (WS4-07) ---

test_that("auto mode falls back to the CLI when a native run fails", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  testthat::local_mocked_bindings(
    opensimAvailable = function(...) TRUE,
    opensimCLIAvailable = function(...) TRUE,
    .opensim_run_tool_native = function(...) stop("native boom"),
    .opensim_run_tool_cli = function(...) list(execution = "cli", status = 0L)
  )

  expect_warning(
    res <- opensimRunTool(tmp, execution = "auto", tool_type = "ik"),
    "falling back to the opensim-cmd CLI"
  )
  expect_identical(res$execution, "cli")
})

test_that("explicit native execution does not silently fall back to the CLI", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  testthat::local_mocked_bindings(
    opensimAvailable = function(...) TRUE,
    opensimCLIAvailable = function(...) TRUE,
    .opensim_run_tool_native = function(...) stop("native boom"),
    .opensim_run_tool_cli = function(...) list(execution = "cli", status = 0L)
  )

  expect_error(
    opensimRunTool(tmp, execution = "native", tool_type = "ik"),
    "native boom"
  )
})

test_that("auto mode re-raises the native error when no CLI is available", {
  tmp <- tempfile(fileext = ".xml")
  writeLines("<OpenSimDocument/>", tmp)

  testthat::local_mocked_bindings(
    opensimAvailable = function(...) TRUE,
    opensimCLIAvailable = function(...) FALSE,
    .opensim_run_tool_native = function(...) stop("native boom")
  )

  expect_error(
    opensimRunTool(tmp, execution = "auto", tool_type = "ik"),
    "native boom"
  )
})

# --- gated CLI integration (runs in the OpenSim CI job) ---

test_that("opensimRunIK executes a setup through the opensim-cmd CLI", {
  skip_if_no_opensim_cli()
  setup <- Sys.getenv("PHYSIO_OPENSIM_IK_SETUP", unset = "")
  skip_if(!nzchar(setup) || !file.exists(setup),
          "No IK setup provided (set PHYSIO_OPENSIM_IK_SETUP)")

  res <- opensimRunIK(setup, execution = "cli", fail_on_error = TRUE)
  expect_identical(res$execution, "cli")
  expect_identical(res$status, 0L)
})
