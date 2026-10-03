#' Path to a bundled OpenSim setup-template XML
#'
#' Returns the path of a setup-template XML shipped with \pkg{PhysioOpenSim},
#' suitable as the \code{template_file} argument of the
#' \code{opensimWrite*SetupFromTemplate()} functions. Each template is a minimal
#' OpenSim tool document whose fields (model, marker/coordinates, output, time
#' range, external loads) are substituted by those writers.
#'
#' @param tool Which tool template to return: one of \code{"ik"}, \code{"id"},
#'   \code{"so"}, \code{"cmc"}, \code{"rra"}, \code{"analyze"}, \code{"generic"}.
#' @return An absolute path to the bundled \code{<tool>_setup_template.xml}.
#' @seealso [opensimWriteIKSetupFromTemplate()], [opensimWriteIDSetupFromTemplate()],
#'   [opensimWriteSOSetupFromTemplate()]
#' @export
#' @examples
#' opensimTemplatePath("ik")
opensimTemplatePath <- function(tool = c("ik", "id", "so", "cmc", "rra",
                                         "analyze", "generic")) {
  tool <- match.arg(tool)
  path <- system.file("extdata", paste0(tool, "_setup_template.xml"),
                      package = "PhysioOpenSim")
  if (!nzchar(path)) {
    stop("Bundled setup template for '", tool, "' not found; reinstall PhysioOpenSim.",
         call. = FALSE)
  }
  path
}

#' Write OpenSim Tool Setup XML from Template
#'
#' Replaces tag values in an existing OpenSim setup XML template.
#' This function is tool-agnostic and can be used for IK/ID/SO/RRA/CMC templates.
#'
#' @param template_file Path to template XML.
#' @param output_file Path to output XML.
#' @param fields Named list of replacement values keyed by XML tag name.
#' @param strict If `TRUE`, error when a tag in `fields` is missing in template.
#' @return A named list with `output_file`, `applied_tags`, and `missing_tags`.
#' @export
#' @examples
#' # Create a minimal template in a temp file
#' tpl <- tempfile(fileext = ".xml")
#' writeLines(c(
#'   "<OpenSimDocument>",
#'   "  <model_file>Unassigned</model_file>",
#'   "  <time_range>0 1</time_range>",
#'   "</OpenSimDocument>"
#' ), tpl)
#'
#' out <- tempfile(fileext = ".xml")
#' result <- opensimWriteToolSetupFromTemplate(
#'   template_file = tpl,
#'   output_file = out,
#'   fields = list(model_file = "my_model.osim", time_range = "0.5 2.0")
#' )
#' result$applied_tags
#' readLines(result$output_file)
opensimWriteToolSetupFromTemplate <- function(template_file,
                                              output_file,
                                              fields,
                                              strict = TRUE) {
  if (!is.character(template_file) || length(template_file) != 1L || is.na(template_file) || !nzchar(template_file)) {
    stop("`template_file` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!file.exists(template_file)) {
    stop("Template XML does not exist: ", template_file, call. = FALSE)
  }
  if (!is.character(output_file) || length(output_file) != 1L || is.na(output_file) || !nzchar(output_file)) {
    stop("`output_file` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.list(fields) || is.null(names(fields)) || any(!nzchar(names(fields)))) {
    stop("`fields` must be a named list.", call. = FALSE)
  }
  if (!is.logical(strict) || length(strict) != 1L || is.na(strict)) {
    stop("`strict` must be a non-missing logical scalar.", call. = FALSE)
  }

  tpl_path <- normalizePath(template_file, winslash = "/", mustWork = TRUE)
  xml <- paste(readLines(tpl_path, warn = FALSE), collapse = "\n")

  applied <- character()
  missing <- character()

  for (tag in names(fields)) {
    value <- .opensim_as_scalar_string(fields[[tag]], arg = paste0("fields[['", tag, "']]"))
    pattern <- sprintf("(<%s>)(.*?)(</%s>)", tag, tag)

    if (!grepl(pattern, xml, perl = TRUE)) {
      missing <- c(missing, tag)
      next
    }

    replacement <- paste0("\\1", value, "\\3")
    xml <- gsub(pattern, replacement, xml, perl = TRUE)
    applied <- c(applied, tag)
  }

  if (isTRUE(strict) && length(missing) > 0L) {
    stop(
      "Tags not found in template: ", paste(missing, collapse = ", "),
      ". Use `strict = FALSE` to allow partial replacements.",
      call. = FALSE
    )
  }
  if (length(missing) > 0L) {
    warning(
      "Some tags were not found in template: ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  out_dir <- dirname(output_file)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  writeLines(strsplit(xml, "\n", fixed = TRUE)[[1]], output_file, useBytes = TRUE)

  list(
    output_file = normalizePath(output_file, winslash = "/", mustWork = TRUE),
    applied_tags = unname(applied),
    missing_tags = unname(missing)
  )
}

#' Write IK Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common Inverse Kinematics tags.
#'
#' @param template_file Path to IK template XML.
#' @param output_file Path to output IK setup XML.
#' @param model_file Path to `.osim` model.
#' @param marker_file Path to marker trajectory file (typically `.trc`).
#' @param output_motion_file Path to IK output motion file (`.mot`).
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteIKSetupFromTemplate(
#'   template_file = "ik_template.xml",
#'   output_file = "ik_setup.xml",
#'   model_file = "gait2392.osim",
#'   marker_file = "walking.trc",
#'   output_motion_file = "ik_output.mot",
#'   time_range = c(0.5, 2.0)
#' )
#' }
opensimWriteIKSetupFromTemplate <- function(template_file,
                                            output_file,
                                            model_file,
                                            marker_file,
                                            output_motion_file,
                                            time_range = NULL,
                                            results_directory = NULL,
                                            extra_fields = list(),
                                            strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE),
    marker_file = .opensim_norm_path(marker_file, must_exist = TRUE),
    output_motion_file = .opensim_norm_path(output_motion_file, must_exist = FALSE)
  )
  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' Write ID Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common Inverse Dynamics tags.
#'
#' @param template_file Path to ID template XML.
#' @param output_file Path to output ID setup XML.
#' @param model_file Path to `.osim` model.
#' @param coordinates_file Path to coordinates/motion file (typically `.mot`).
#' @param output_gen_force_file Path to generalized force output file (`.sto`).
#' @param external_loads_file Optional path to external loads XML.
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param lowpass_cutoff_frequency_for_coordinates Optional numeric cutoff.
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteIDSetupFromTemplate(
#'   template_file = "id_template.xml",
#'   output_file = "id_setup.xml",
#'   model_file = "gait2392.osim",
#'   coordinates_file = "ik_output.mot",
#'   output_gen_force_file = "id_output.sto",
#'   time_range = c(0.5, 2.0)
#' )
#' }
opensimWriteIDSetupFromTemplate <- function(template_file,
                                            output_file,
                                            model_file,
                                            coordinates_file,
                                            output_gen_force_file,
                                            external_loads_file = NULL,
                                            time_range = NULL,
                                            lowpass_cutoff_frequency_for_coordinates = NULL,
                                            results_directory = NULL,
                                            extra_fields = list(),
                                            strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE),
    coordinates_file = .opensim_norm_path(coordinates_file, must_exist = TRUE),
    output_gen_force_file = .opensim_norm_path(output_gen_force_file, must_exist = FALSE)
  )
  if (!is.null(external_loads_file)) {
    fields$external_loads_file <- .opensim_norm_path(external_loads_file, must_exist = TRUE)
  }
  if (!is.null(lowpass_cutoff_frequency_for_coordinates)) {
    fields$lowpass_cutoff_frequency_for_coordinates <- .opensim_as_scalar_text(
      lowpass_cutoff_frequency_for_coordinates,
      arg = "lowpass_cutoff_frequency_for_coordinates"
    )
  }

  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' Write SO Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common Static Optimization tags.
#'
#' @param template_file Path to SO template XML.
#' @param output_file Path to output SO setup XML.
#' @param model_file Path to `.osim` model.
#' @param coordinates_file Path to coordinates/motion file (typically `.mot`).
#' @param external_loads_file Optional path to external loads XML.
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteSOSetupFromTemplate(
#'   template_file = "so_template.xml",
#'   output_file = "so_setup.xml",
#'   model_file = "gait2392.osim",
#'   coordinates_file = "ik_output.mot",
#'   time_range = c(0.5, 2.0)
#' )
#' }
opensimWriteSOSetupFromTemplate <- function(template_file,
                                            output_file,
                                            model_file,
                                            coordinates_file,
                                            external_loads_file = NULL,
                                            time_range = NULL,
                                            results_directory = NULL,
                                            extra_fields = list(),
                                            strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE),
    coordinates_file = .opensim_norm_path(coordinates_file, must_exist = TRUE)
  )
  if (!is.null(external_loads_file)) {
    fields$external_loads_file <- .opensim_norm_path(external_loads_file, must_exist = TRUE)
  }
  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' Write Analyze Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common AnalyzeTool tags.
#'
#' @param template_file Path to Analyze template XML.
#' @param output_file Path to output Analyze setup XML.
#' @param model_file Path to `.osim` model.
#' @param coordinates_file Optional path to coordinates/motion file.
#' @param external_loads_file Optional path to external loads XML.
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteAnalyzeSetupFromTemplate(
#'   template_file = "analyze_template.xml",
#'   output_file = "analyze_setup.xml",
#'   model_file = "gait2392.osim",
#'   coordinates_file = "ik_output.mot"
#' )
#' }
opensimWriteAnalyzeSetupFromTemplate <- function(template_file,
                                                 output_file,
                                                 model_file,
                                                 coordinates_file = NULL,
                                                 external_loads_file = NULL,
                                                 time_range = NULL,
                                                 results_directory = NULL,
                                                 extra_fields = list(),
                                                 strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE)
  )
  if (!is.null(coordinates_file)) {
    fields$coordinates_file <- .opensim_norm_path(coordinates_file, must_exist = TRUE)
  }
  if (!is.null(external_loads_file)) {
    fields$external_loads_file <- .opensim_norm_path(external_loads_file, must_exist = TRUE)
  }
  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' Write RRA Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common RRATool tags.
#'
#' @param template_file Path to RRA template XML.
#' @param output_file Path to output RRA setup XML.
#' @param model_file Path to `.osim` model.
#' @param desired_kinematics_file Optional path to desired kinematics file.
#' @param external_loads_file Optional path to external loads XML.
#' @param output_model_file Optional path to adjusted model output (`.osim`).
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteRRASetupFromTemplate(
#'   template_file = "rra_template.xml",
#'   output_file = "rra_setup.xml",
#'   model_file = "gait2392.osim",
#'   desired_kinematics_file = "ik_output.mot",
#'   output_model_file = "gait2392_rra.osim"
#' )
#' }
opensimWriteRRASetupFromTemplate <- function(template_file,
                                             output_file,
                                             model_file,
                                             desired_kinematics_file = NULL,
                                             external_loads_file = NULL,
                                             output_model_file = NULL,
                                             time_range = NULL,
                                             results_directory = NULL,
                                             extra_fields = list(),
                                             strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE)
  )
  if (!is.null(desired_kinematics_file)) {
    fields$desired_kinematics_file <- .opensim_norm_path(desired_kinematics_file, must_exist = TRUE)
  }
  if (!is.null(external_loads_file)) {
    fields$external_loads_file <- .opensim_norm_path(external_loads_file, must_exist = TRUE)
  }
  if (!is.null(output_model_file)) {
    fields$output_model_file <- .opensim_norm_path(output_model_file, must_exist = FALSE)
  }
  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' Write CMC Setup XML from Template
#'
#' Convenience wrapper around [opensimWriteToolSetupFromTemplate()] for
#' common CMCTool tags.
#'
#' @param template_file Path to CMC template XML.
#' @param output_file Path to output CMC setup XML.
#' @param model_file Path to `.osim` model.
#' @param desired_kinematics_file Optional path to desired kinematics file.
#' @param external_loads_file Optional path to external loads XML.
#' @param time_range Optional numeric length-2 vector (`c(start, end)`).
#' @param results_directory Optional output directory.
#' @param extra_fields Optional named list of additional XML tag replacements.
#' @param strict Passed to [opensimWriteToolSetupFromTemplate()].
#' @return See [opensimWriteToolSetupFromTemplate()].
#' @export
#' @examples
#' \dontrun{
#' opensimWriteCMCSetupFromTemplate(
#'   template_file = "cmc_template.xml",
#'   output_file = "cmc_setup.xml",
#'   model_file = "gait2392.osim",
#'   desired_kinematics_file = "ik_output.mot"
#' )
#' }
opensimWriteCMCSetupFromTemplate <- function(template_file,
                                             output_file,
                                             model_file,
                                             desired_kinematics_file = NULL,
                                             external_loads_file = NULL,
                                             time_range = NULL,
                                             results_directory = NULL,
                                             extra_fields = list(),
                                             strict = TRUE) {
  fields <- list(
    model_file = .opensim_norm_path(model_file, must_exist = TRUE)
  )
  if (!is.null(desired_kinematics_file)) {
    fields$desired_kinematics_file <- .opensim_norm_path(desired_kinematics_file, must_exist = TRUE)
  }
  if (!is.null(external_loads_file)) {
    fields$external_loads_file <- .opensim_norm_path(external_loads_file, must_exist = TRUE)
  }
  fields <- utils::modifyList(fields, .opensim_optional_time_and_dir(time_range, results_directory))
  fields <- utils::modifyList(fields, extra_fields)

  opensimWriteToolSetupFromTemplate(
    template_file = template_file,
    output_file = output_file,
    fields = fields,
    strict = strict
  )
}

#' @keywords internal
.opensim_optional_time_and_dir <- function(time_range, results_directory) {
  out <- list()

  if (!is.null(time_range)) {
    if (!is.numeric(time_range) || length(time_range) != 2L || any(is.na(time_range))) {
      stop("`time_range` must be NULL or numeric length-2 vector.", call. = FALSE)
    }
    out$time_range <- paste(format(time_range, scientific = FALSE, trim = TRUE), collapse = " ")
  }
  if (!is.null(results_directory)) {
    out$results_directory <- .opensim_norm_path(results_directory, must_exist = FALSE)
  }

  out
}

#' @keywords internal
.opensim_norm_path <- function(path, must_exist = TRUE) {
  p <- .opensim_as_scalar_string(path, arg = "path")
  normalizePath(p, winslash = "/", mustWork = isTRUE(must_exist))
}

#' @keywords internal
.opensim_as_scalar_string <- function(x, arg = "value") {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`", arg, "` must be a non-empty character scalar.", call. = FALSE)
  }
  x
}

#' @keywords internal
.opensim_as_scalar_text <- function(x, arg = "value") {
  if (length(x) != 1L || is.na(x)) {
    stop("`", arg, "` must be a non-missing scalar.", call. = FALSE)
  }
  if (is.character(x)) {
    if (!nzchar(x)) stop("`", arg, "` must be non-empty.", call. = FALSE)
    return(x)
  }
  if (is.numeric(x) || is.logical(x) || is.integer(x)) {
    return(as.character(x))
  }
  stop("`", arg, "` must be character/numeric/logical scalar.", call. = FALSE)
}
