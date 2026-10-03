# opensimDiagnostics() environment report (WS4-07)

test_that("opensimDiagnostics returns a complete, well-typed report", {
  d <- opensimDiagnostics()
  expect_s3_class(d, "opensim_diagnostics")
  expect_identical(d$package, "PhysioOpenSim")
  expect_type(d$native_available, "logical")
  expect_length(d$native_available, 1)
  expect_type(d$detect_method, "character")
  expect_type(d$cli_available, "logical")
  expect_true(d$backend %in% c("native", "cli", "none"))
})

test_that("opensimDiagnostics is consistent with the build and CLI helpers", {
  d <- opensimDiagnostics()
  expect_identical(d$native_available, opensimAvailable())
  expect_identical(d$detect_method, opensimBuildConfig()$detect_method)
  expect_identical(d$cli_available, opensimCLIAvailable())

  # backend reflects native > cli > none precedence
  expected_backend <- if (d$native_available) {
    "native"
  } else if (d$cli_available) {
    "cli"
  } else {
    "none"
  }
  expect_identical(d$backend, expected_backend)
})

test_that("opensimDiagnostics reports 'none' without native or CLI OpenSim", {
  skip_if(opensimAvailable(), "OpenSim-enabled build")
  skip_if(opensimCLIAvailable(), "opensim-cmd available")

  d <- opensimDiagnostics()
  expect_false(d$native_available)
  expect_identical(d$backend, "none")
  expect_true(is.na(d$opensim_version))
  expect_true(is.na(d$simbody_version))
  expect_true(is.na(d$cli_path))
})

test_that("opensimDiagnostics prints a human-readable summary", {
  d <- opensimDiagnostics()
  expect_output(print(d), "PhysioOpenSim diagnostics")
  expect_output(print(d), "default backend")
})
