# --- Generic template writer ---

test_that("opensimWriteToolSetupFromTemplate replaces tag values", {
  tpl <- make_test_template(
    tags = list(model_file = "old_model.osim", marker_file = "old_markers.trc")
  )
  out <- tempfile(fileext = ".xml")

  result <- opensimWriteToolSetupFromTemplate(
    template_file = tpl,
    output_file = out,
    fields = list(model_file = "new_model.osim", marker_file = "new_markers.trc")
  )

  expect_true(file.exists(result$output_file))
  txt <- paste(readLines(result$output_file, warn = FALSE), collapse = "\n")
  expect_match(txt, "<model_file>new_model.osim</model_file>", fixed = TRUE)
  expect_match(txt, "<marker_file>new_markers.trc</marker_file>", fixed = TRUE)
  expect_identical(sort(result$applied_tags), c("marker_file", "model_file"))
  expect_length(result$missing_tags, 0)
})

test_that("opensimWriteToolSetupFromTemplate errors on missing tags in strict mode", {
  tpl <- make_test_template(tags = list(model_file = "old.osim"))
  out <- tempfile(fileext = ".xml")

  expect_error(
    opensimWriteToolSetupFromTemplate(
      template_file = tpl,
      output_file = out,
      fields = list(missing_tag = "x"),
      strict = TRUE
    ),
    "Tags not found"
  )
})

test_that("opensimWriteToolSetupFromTemplate warns on missing tags in non-strict mode", {
  tpl <- make_test_template(tags = list(model_file = "old.osim"))
  out <- tempfile(fileext = ".xml")

  expect_warning(
    result <- opensimWriteToolSetupFromTemplate(
      template_file = tpl,
      output_file = out,
      fields = list(missing_tag = "x"),
      strict = FALSE
    ),
    "not found"
  )
  expect_identical(result$missing_tags, "missing_tag")
  expect_length(result$applied_tags, 0)
})

test_that("opensimWriteToolSetupFromTemplate validates template_file", {
  expect_error(
    opensimWriteToolSetupFromTemplate("nonexistent.xml", tempfile(), list(a = "b")),
    "does not exist"
  )
  expect_error(
    opensimWriteToolSetupFromTemplate("", tempfile(), list(a = "b")),
    "non-empty character scalar"
  )
})

test_that("opensimWriteToolSetupFromTemplate validates output_file", {
  tpl <- make_test_template()
  expect_error(
    opensimWriteToolSetupFromTemplate(tpl, "", list(a = "b")),
    "non-empty character scalar"
  )
})

test_that("opensimWriteToolSetupFromTemplate validates fields", {
  tpl <- make_test_template()
  expect_error(
    opensimWriteToolSetupFromTemplate(tpl, tempfile(), "not_a_list"),
    "named list"
  )
  expect_error(
    opensimWriteToolSetupFromTemplate(tpl, tempfile(), list("unnamed")),
    "named list"
  )
})

test_that("opensimWriteToolSetupFromTemplate validates strict", {
  tpl <- make_test_template()
  expect_error(
    opensimWriteToolSetupFromTemplate(tpl, tempfile(), list(a = "b"), strict = NA),
    "non-missing logical"
  )
})

test_that("opensimWriteToolSetupFromTemplate creates output directory", {
  tpl <- make_test_template(tags = list(model_file = "old.osim"))
  out <- file.path(tempdir(), "subdir_test_opensim", "out.xml")
  on.exit(unlink(dirname(out), recursive = TRUE), add = TRUE)

  result <- opensimWriteToolSetupFromTemplate(
    template_file = tpl,
    output_file = out,
    fields = list(model_file = "new.osim")
  )
  expect_true(file.exists(result$output_file))
})

test_that("opensimWriteToolSetupFromTemplate handles multiple same-tag replacements", {
  # Template with duplicate tags (unusual but possible)
  f <- tempfile(fileext = ".xml")
  writeLines(c(
    "<root>",
    "  <model_file>first</model_file>",
    "  <model_file>second</model_file>",
    "</root>"
  ), f)
  out <- tempfile(fileext = ".xml")

  result <- opensimWriteToolSetupFromTemplate(f, out, list(model_file = "replaced"))
  txt <- readLines(result$output_file, warn = FALSE)
  matches <- grep("replaced", txt)
  expect_length(matches, 2)
})

# --- Bundled template fixtures ---

test_that("bundled IK template is loadable", {
  path <- testdata_template("ik_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available (development install)")
  expect_true(file.exists(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(txt, "model_file", fixed = TRUE)
  expect_match(txt, "marker_file", fixed = TRUE)
})

test_that("bundled ID template is loadable", {
  path <- testdata_template("id_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(txt, "coordinates_file", fixed = TRUE)
})

test_that("bundled SO template is loadable", {
  path <- testdata_template("so_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  expect_true(file.exists(path))
})

test_that("bundled Analyze template is loadable", {
  path <- testdata_template("analyze_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  expect_true(file.exists(path))
})

test_that("bundled RRA template is loadable", {
  path <- testdata_template("rra_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(txt, "desired_kinematics_file", fixed = TRUE)
})

test_that("bundled CMC template is loadable", {
  path <- testdata_template("cmc_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(txt, "desired_kinematics_file", fixed = TRUE)
})

test_that("bundled generic template is loadable", {
  path <- testdata_template("generic_setup_template.xml")
  skip_if(is.null(path), "Bundled testdata not available")
  expect_true(file.exists(path))
})

# --- Convenience wrappers ---

test_that("opensimWriteIKSetupFromTemplate applies IK-specific fields", {
  model <- make_dummy_file(".osim")
  marker <- make_dummy_file(".trc")

  tpl <- make_test_template(
    tags = list(
      model_file = "Unassigned",
      marker_file = "Unassigned",
      output_motion_file = "Unassigned",
      time_range = "0 1",
      results_directory = "./"
    ),
    tool_name = "InverseKinematicsTool"
  )
  out <- tempfile(fileext = ".xml")
  mot_out <- tempfile(fileext = ".mot")

  result <- opensimWriteIKSetupFromTemplate(
    template_file = tpl,
    output_file = out,
    model_file = model,
    marker_file = marker,
    output_motion_file = mot_out,
    time_range = c(0.5, 2.0)
  )

  txt <- paste(readLines(result$output_file, warn = FALSE), collapse = "\n")
  expect_match(txt, normalizePath(model, winslash = "/"), fixed = TRUE)
  expect_match(txt, normalizePath(marker, winslash = "/"), fixed = TRUE)
  expect_match(txt, "0.5 2", fixed = TRUE)
})

test_that("opensimWriteAnalyzeSetupFromTemplate applies common fields", {
  model <- make_dummy_file(".osim")
  coord <- make_dummy_file(".mot")

  tpl <- make_test_template(
    tags = list(
      model_file = "old.osim",
      coordinates_file = "old.mot"
    ),
    tool_name = "AnalyzeTool"
  )
  out <- tempfile(fileext = ".xml")

  res <- opensimWriteAnalyzeSetupFromTemplate(
    template_file = tpl,
    output_file = out,
    model_file = model,
    coordinates_file = coord
  )
  txt <- paste(readLines(res$output_file, warn = FALSE), collapse = "\n")
  expect_match(txt, normalizePath(model, winslash = "/"), fixed = TRUE)
  expect_match(txt, normalizePath(coord, winslash = "/"), fixed = TRUE)
})

test_that("opensimWriteRRASetupFromTemplate applies desired/output fields", {
  model <- make_dummy_file(".osim")
  desired <- make_dummy_file(".mot")
  output_model <- tempfile(fileext = ".osim")

  tpl <- make_test_template(
    tags = list(
      model_file = "old.osim",
      desired_kinematics_file = "old_desired.mot",
      output_model_file = "old_out.osim"
    ),
    tool_name = "RRATool"
  )
  out <- tempfile(fileext = ".xml")

  res <- opensimWriteRRASetupFromTemplate(
    template_file = tpl,
    output_file = out,
    model_file = model,
    desired_kinematics_file = desired,
    output_model_file = output_model
  )
  txt <- paste(readLines(res$output_file, warn = FALSE), collapse = "\n")
  expect_match(txt, normalizePath(model, winslash = "/"), fixed = TRUE)
  expect_match(txt, normalizePath(desired, winslash = "/"), fixed = TRUE)
  expect_match(txt, normalizePath(output_model, winslash = "/", mustWork = FALSE), fixed = TRUE)
})

test_that("opensimWriteCMCSetupFromTemplate applies desired field", {
  model <- make_dummy_file(".osim")
  desired <- make_dummy_file(".mot")

  tpl <- make_test_template(
    tags = list(
      model_file = "old.osim",
      desired_kinematics_file = "old_desired.mot"
    ),
    tool_name = "CMCTool"
  )
  out <- tempfile(fileext = ".xml")

  res <- opensimWriteCMCSetupFromTemplate(
    template_file = tpl,
    output_file = out,
    model_file = model,
    desired_kinematics_file = desired
  )
  txt <- paste(readLines(res$output_file, warn = FALSE), collapse = "\n")
  expect_match(txt, normalizePath(model, winslash = "/"), fixed = TRUE)
  expect_match(txt, normalizePath(desired, winslash = "/"), fixed = TRUE)
})
