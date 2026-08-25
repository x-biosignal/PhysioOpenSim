test_that("opensimCLIPath validates cli argument type", {
  expect_error(opensimCLIPath(123), "non-empty character scalar")
  expect_error(opensimCLIPath(NA_character_), "non-empty character scalar")
  # Empty string falls through to default "opensim-cmd", so it won't hit

  # the validation path; we test it indirectly via missing command check
})

test_that("opensimCLIPath errors for missing command", {
  expect_error(
    opensimCLIPath("definitely_missing_opensim_cli_command_12345"),
    "not found"
  )
})

test_that("opensimCLIPath errors for non-existent absolute path", {
  expect_error(
    opensimCLIPath("/no/such/path/opensim-cmd"),
    "does not exist"
  )
})

test_that("opensimCLIAvailable returns FALSE for missing command", {
  expect_false(opensimCLIAvailable("definitely_missing_opensim_cli_command_12345"))
})

test_that("opensimCLIAvailable returns FALSE for non-existent path", {
  expect_false(opensimCLIAvailable("/no/such/path/opensim-cmd"))
})

test_that("opensimCLIPath respects OPENSIM_CLI env var", {
  # Create a dummy executable
  tmp <- tempfile("fake_opensim_")
  writeLines("#!/bin/sh\necho ok", tmp)
  Sys.chmod(tmp, "755")

  withr::with_envvar(c(OPENSIM_CLI = tmp), {
    path <- opensimCLIPath()
    expect_true(nzchar(path))
    expect_true(file.exists(path))
  })
})

test_that("opensimCLIPath resolves system commands on PATH", {
  # Use a command known to exist on any system
  # This tests the Sys.which branch
  skip_on_os("windows")
  path <- opensimCLIPath("ls")
  expect_true(nzchar(path))
})
