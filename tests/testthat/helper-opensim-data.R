# Helper functions for PhysioOpenSim tests
#
# Loaded automatically by testthat before test files.

#' Create a temporary XML template with given tags
#'
#' @param tags Named character vector of tag names and default values.
#' @param tool_name Tool element name (default "GenericTool").
#' @return Path to the temporary XML file.
make_test_template <- function(tags = list(model_file = "Unassigned"),
                               tool_name = "GenericTool") {
  body <- vapply(names(tags), function(t) {
    sprintf("    <%s>%s</%s>", t, tags[[t]], t)
  }, character(1))

  lines <- c(
    '<?xml version="1.0" encoding="UTF-8" ?>',
    '<OpenSimDocument Version="40000">',
    sprintf('  <%s name="test">', tool_name),
    body,
    sprintf('  </%s>', tool_name),
    '</OpenSimDocument>'
  )
  f <- tempfile(fileext = ".xml")
  writeLines(lines, f)
  f
}

#' Create a dummy file (for path normalization in wrappers)
#'
#' @param ext File extension including dot.
#' @param content Content to write.
#' @return Path to the temporary file.
make_dummy_file <- function(ext = ".osim", content = "dummy") {
  f <- tempfile(fileext = ext)
  writeLines(content, f)
  f
}

#' Resolve a bundled inst/testdata/ file
#'
#' Works both in development (inst/testdata/) and installed (testdata/) layout.
#'
#' @param filename Filename within testdata directory.
#' @return Absolute path or NULL if not found.
testdata_template <- function(filename) {
  path <- system.file("extdata", filename, package = "PhysioOpenSim")
  if (nzchar(path)) return(path)
  path <- system.file("testdata", filename, package = "PhysioOpenSim")  # legacy layout
  if (nzchar(path)) return(path)
  NULL
}

#' Skip test if native OpenSim support is not available
skip_if_no_opensim <- function() {

  skip_if_not(opensimAvailable(), "Native OpenSim support not available")
}

#' Skip test if OpenSim CLI is not available
skip_if_no_opensim_cli <- function() {
  skip_if_not(opensimCLIAvailable(), "OpenSim CLI not available")
}
