test_that("opensimLoadModel validates path argument", {
  expect_error(opensimLoadModel(""), "non-empty character scalar")
  expect_error(opensimLoadModel(123), "non-empty character scalar")
  expect_error(opensimLoadModel(NA_character_), "non-empty character scalar")
  expect_error(opensimLoadModel("this/file/does/not/exist.osim"))
})

test_that("opensimModelSummary validates path argument", {
  expect_error(opensimModelSummary(""), "non-empty character scalar")
  expect_error(opensimModelSummary(123), "non-empty character scalar")
})

test_that("model-handle APIs validate pointer input", {
  expect_error(opensimModelIsInitialized(list()), "PhysioOpenSimModel")
  expect_error(opensimModelInitialize(list()), "PhysioOpenSimModel")
  expect_error(opensimModelComponents(list()), "PhysioOpenSimModel")
  expect_error(opensimModelName(list()), "PhysioOpenSimModel")
  expect_error(opensimSetModelName(list(), "m"), "PhysioOpenSimModel")
  expect_error(opensimFinalizeConnections(list()), "PhysioOpenSimModel")
  expect_error(opensimSaveModel(list(), tempfile(fileext = ".osim")), "PhysioOpenSimModel")
})

test_that("opensimSetModelName validates name argument", {
  # name validation happens before model validation for empty/NA values
  expect_error(opensimSetModelName(list(), ""), "non-empty character scalar")
  expect_error(opensimSetModelName(list(), NA_character_), "non-empty character scalar")
  # With valid name, model validation triggers
  expect_error(opensimSetModelName(list(), "valid_name"), "PhysioOpenSimModel")
})

test_that("opensimModelSummary gives informative error when OpenSim is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build; this test targets fallback behavior")

  tmp <- tempfile(fileext = ".osim")
  writeLines("<OpenSimDocument></OpenSimDocument>", tmp)
  expect_error(opensimModelSummary(tmp), "compiled without OpenSim support")
})

test_that("opensimLoadModel gives informative error when OpenSim is unavailable", {
  skip_if(opensimAvailable(), "OpenSim-enabled build; this test targets fallback behavior")

  tmp <- tempfile(fileext = ".osim")
  writeLines("<OpenSimDocument></OpenSimDocument>", tmp)
  expect_error(opensimLoadModel(tmp), "compiled without OpenSim support")
})

# A real .osim model is provided by the OpenSim CI job via PHYSIO_OPENSIM_MODEL
# (e.g. gait2392); locally the env var is unset and these tests skip.
opensim_test_model <- function() {
  path <- Sys.getenv("PHYSIO_OPENSIM_MODEL", unset = "")
  if (!nzchar(path) || !file.exists(path)) {
    # fall back to the bundled arm26 model (VAL-06) so OpenSim-enabled builds
    # validate the native parser without needing the env var
    path <- system.file("extdata", "arm26.osim", package = "PhysioOpenSim")
  }
  if (!nzchar(path) || !file.exists(path)) return(NULL)
  path
}

test_that("opensimModelSummary reports a real model's structure", {
  skip_if_no_opensim()
  model_path <- opensim_test_model()
  skip_if(is.null(model_path),
          "No .osim model available (set PHYSIO_OPENSIM_MODEL)")

  summary <- opensimModelSummary(model_path)
  expect_true(is.list(summary))
  expect_true(all(c("model_name", "n_bodies", "n_coordinates") %in%
                    names(summary)))
  expect_gt(summary$n_bodies, 0)
  expect_gt(summary$n_coordinates, 0)
})

test_that("model lifecycle works end-to-end with native OpenSim", {
  skip_if_no_opensim()
  model_path <- opensim_test_model()
  skip_if(is.null(model_path),
          "No .osim model available (set PHYSIO_OPENSIM_MODEL)")

  model <- opensimLoadModel(model_path)
  opensimModelInitialize(model)
  expect_true(opensimModelIsInitialized(model))
  expect_true(nzchar(opensimModelName(model)))

  opensimSetModelName(model, "physio_roundtrip")
  expect_identical(opensimModelName(model), "physio_roundtrip")

  out <- tempfile(fileext = ".osim")
  opensimSaveModel(model, out)
  expect_true(file.exists(out))
})
