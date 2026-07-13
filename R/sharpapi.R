BASE_URL <- "https://api.sharpapi.io/api/v1"

sharpapi_key <- function() {
  key <- Sys.getenv("SHARPAPI_KEY")
  if (!nzchar(key)) {
    stop("Set SHARPAPI_KEY. Get a free key at https://sharpapi.io", call. = FALSE)
  }
  key
}

sharpapi_get <- function(path, ...) {
  params <- list(...)
  req <- httr2::request(paste0(BASE_URL, path))
  req <- httr2::req_headers(req, `X-API-Key` = sharpapi_key())
  req <- httr2::req_user_agent(req, "sharpapi-r (https://github.com/Sharp-API/sharpapi-r)")
  if (length(params) > 0) {
    req <- do.call(httr2::req_url_query, c(list(req), params))
  }
  resp <- httr2::req_perform(req)
  jsonlite::fromJSON(httr2::resp_body_string(resp))
}

#' List sports with live event counts
#' @export
sharpapi_sports <- function() {
  as.data.frame(sharpapi_get("/sports")$data)
}

#' Current odds as a data frame
#' @param ... Filters passed to the API, e.g. sport = "soccer",
#'   league = "mlb", sportsbook = "pinnacle", market_type = "moneyline",
#'   limit = 500.
#' @export
sharpapi_odds <- function(...) {
  as.data.frame(sharpapi_get("/odds", ...)$data)
}

#' Positive expected value opportunities (Pro tier or higher)
#' @param ... Filters passed to the API.
#' @export
sharpapi_ev <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/ev", ...)$data)
}

#' Arbitrage opportunities (Hobby tier or higher)
#' @param ... Filters passed to the API.
#' @export
sharpapi_arbitrage <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/arbitrage", ...)$data)
}
