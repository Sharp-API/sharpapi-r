test_that("sharpapi_get() targets the documented base URL and path", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_equal(got$request$url, "https://api.sharpapi.io/api/v1/sports")
})

test_that("the API key travels in the X-API-Key header, not the query string", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_identical(got$request$headers[["X-API-Key"]], "test-key-123")
  # A key leaked into the URL would end up in server logs and browser history.
  expect_false(grepl("test-key-123", got$request$url, fixed = TRUE))
})

test_that("a user agent identifying the client is sent", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_match(got$request$options$useragent, "sharpapi-r", fixed = TRUE)
})

test_that("dots become query parameters", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ODDS_JSON, sharpapi_odds(sport = "baseball", limit = 5))

  expect_match(got$request$url, "sport=baseball", fixed = TRUE)
  expect_match(got$request$url, "limit=5", fixed = TRUE)
})

test_that("no query string is appended when no filters are given", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ODDS_JSON, sharpapi_odds())

  expect_false(grepl("?", got$request$url, fixed = TRUE))
})

test_that("an HTTP error is raised rather than returned as data", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  # Documented behaviour for a key below the required tier: sharpapi_ev() and
  # sharpapi_arbitrage() "raise an HTTP error rather than returning an empty
  # frame". Assert that, so the docs cannot drift away from the code silently.
  expect_error(
    httr2::with_mocked_responses(
      function(req) fake_json_response('{"error":"tier"}', status = 403L),
      sharpapi_ev(sport = "baseball")
    )
  )
})
