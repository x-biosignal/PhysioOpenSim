test_that("opensimAvailable returns scalar logical", {
  x <- opensimAvailable()
  expect_type(x, "logical")
  expect_length(x, 1)
})

test_that("opensimBuildConfig returns expected fields", {
  cfg <- opensimBuildConfig()
  expect_true(is.list(cfg))
  expect_identical(cfg$package, "PhysioOpenSim")
  expect_type(cfg$opensim_enabled, "logical")
  expect_length(cfg$opensim_enabled, 1)
  expect_type(cfg$detect_method, "character")
  expect_length(cfg$detect_method, 1)
  expect_true(nzchar(cfg$detect_method))
})

test_that("opensimBuildConfig and opensimAvailable are consistent", {
  cfg <- opensimBuildConfig()
  avail <- opensimAvailable()
  expect_identical(cfg$opensim_enabled, avail)
})

test_that("opensimBuildConfig detect_method is a known value", {
  cfg <- opensimBuildConfig()
  # Must match the DETECT_METHOD tokens emitted by ./configure (and Makevars.win).
  known <- c("none", "pkg_config", "opensim_home", "conda_prefix",
             "opensim_cmd", "windows_default", "unknown")
  expect_true(
    cfg$detect_method %in% known,
    info = paste("detect_method:", cfg$detect_method)
  )
})

test_that("opensimCLIAvailable returns scalar logical", {
  x <- opensimCLIAvailable()
  expect_type(x, "logical")
  expect_length(x, 1)
})
