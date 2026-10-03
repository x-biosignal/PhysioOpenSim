library(testthat)
library(PhysioOpenSim)

# VAL-06: parity against a real OpenSim run, from a BUNDLED fixture.
#
# PhysioOpenSim is a thin wrapper: its native model parser and CLI tools require
# an OpenSim-enabled build (opensimAvailable()), so a fully OpenSim-free numeric
# parity is not possible. The always-running check below therefore targets the
# pure-R setup writer, whose output was verified against real OpenSim: OpenSim's
# InverseDynamicsTool loads the PhysioOpenSim-generated setup and reads its
# numeric fields back exactly (recorded in the fixture's id_setup$readback,
# opensim_loaded = TRUE). The native-parser parity against the bundled arm26
# model runs on OpenSim-enabled builds. Fixture/provenance:
# data-raw/opensim_reference.{R,py}; OpenSim 4.6, arm26 from opensim-models @ d9b05d4.

fx_path <- system.file("extdata", "opensim-reference.rds", package = "PhysioOpenSim")

test_that("opensimWriteIDSetupFromTemplate produces an OpenSim-valid ID config", {
  skip_if(fx_path == "", "OpenSim reference fixture not bundled")
  fx <- readRDS(fx_path)
  model <- system.file("extdata", "arm26.osim", package = "PhysioOpenSim")
  skip_if(model == "", "bundled arm26 model not found")

  coords <- tempfile(fileext = ".mot"); loads <- tempfile(fileext = ".xml")
  out <- tempfile(fileext = ".xml")
  file.create(coords); file.create(loads)
  on.exit(unlink(c(coords, loads, out)), add = TRUE)

  opensimWriteIDSetupFromTemplate(
    template_file = opensimTemplatePath("id"),
    output_file = out, model_file = model, coordinates_file = coords,
    external_loads_file = loads, output_gen_force_file = fx$id_setup$output_gen_force_file,
    time_range = fx$id_setup$time_range,
    lowpass_cutoff_frequency_for_coordinates = fx$id_setup$lowpass,
    results_directory = "Results")

  txt <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(txt, "InverseDynamicsTool", fixed = TRUE)
  tr <- as.numeric(strsplit(trimws(sub(
    ".*<time_range>(.*?)</time_range>.*", "\\1", txt)), "\\s+")[[1]])
  lp <- as.numeric(trimws(sub(
    ".*<lowpass_cutoff_frequency_for_coordinates>(.*?)</lowpass_cutoff_frequency_for_coordinates>.*",
    "\\1", txt)))
  # numeric fields must equal what OpenSim actually read back from this writer
  expect_true(isTRUE(fx$id_setup$readback$opensim_loaded))
  expect_equal(tr, c(fx$id_setup$readback$t0, fx$id_setup$readback$t1))
  expect_equal(lp, fx$id_setup$readback$lowpass)
  # The writer normalizes output paths via normalizePath(mustWork = FALSE), which
  # leaves a non-existent relative path unchanged on Linux/macOS but absolutizes
  # it on Windows. Match the tag by basename so the assertion is path-portable.
  expect_match(txt, paste0("<output_gen_force_file>[^<]*",
                           basename(fx$id_setup$output_gen_force_file),
                           "</output_gen_force_file>"))
})

test_that("native parser matches OpenSim's arm26 summary (OpenSim-enabled builds)", {
  skip_if(fx_path == "", "OpenSim reference fixture not bundled")
  skip_if(!opensimAvailable(),
          "native parser needs an OpenSim-enabled build (opensimAvailable() is FALSE)")
  fx <- readRDS(fx_path)
  model <- system.file("extdata", "arm26.osim", package = "PhysioOpenSim")
  s <- opensimModelSummary(model)
  ref <- fx$arm26_summary
  expect_equal(s$model_name, ref$model_name)
  expect_equal(s$n_bodies, ref$n_bodies)
  expect_equal(s$n_coordinates, ref$n_coordinates)
})
