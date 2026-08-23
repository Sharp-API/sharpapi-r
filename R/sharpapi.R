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
#'
#' @return A data frame with one row per sport. Columns include `id`,
#'   `name`, `numerical_id`, `event_count` and `live_count`.
#' @examples
#' \donttest{
#' # Requires SHARPAPI_KEY to be set; get a free key at https://sharpapi.io
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   sports <- sharpapi_sports()
#'   head(sports)
#' }
#' }
#' @export
sharpapi_sports <- function() {
  as.data.frame(sharpapi_get("/sports")$data)
}

#' Current odds as a data frame
#'
#' @param ... Filters passed to the API, e.g. sport = "soccer",
#'   league = "mlb", sportsbook = "pinnacle", market_type = "moneyline",
#'   limit = 500.
#' @return A data frame with one row per odds line. Columns include
#'   `event_id`, `sportsbook`, `market_type`, `selection`, `odds_american`,
#'   `odds_decimal` and `odds_probability`.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   odds <- sharpapi_odds(sport = "baseball", limit = 5)
#'   head(odds)
#' }
#' }
#' @export
sharpapi_odds <- function(...) {
  as.data.frame(sharpapi_get("/odds", ...)$data)
}

#' Positive expected value opportunities
#'
#' Requires a Pro tier key or higher.
#'
#' @param ... Filters passed to the API.
#' @return A data frame with one row per +EV opportunity. Columns include
#'   `event_id`, `sportsbook`, `market_type`, `selection` and `ev_percentage`.
#'   A key below the Pro tier raises an HTTP error rather than returning an
#'   empty frame.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   ev <- sharpapi_ev(sport = "baseball")
#'   head(ev)
#' }
#' }
#' @export
sharpapi_ev <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/ev", ...)$data)
}

#' Arbitrage opportunities
#'
#' Requires a Hobby tier key or higher.
#'
#' @param ... Filters passed to the API.
#' @return A data frame with one row per arbitrage opportunity. Columns
#'   include `event_id`, `sport`, `market_type` and `profit_percent`. The
#'   individual sides live in a nested `legs` column rather than as top-level
#'   fields. A key below the Hobby tier raises an HTTP error rather than
#'   returning an empty frame.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   arb <- sharpapi_arbitrage(sport = "baseball")
#'   head(arb)
#' }
#' }
#' @export
sharpapi_arbitrage <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/arbitrage", ...)$data)
}
