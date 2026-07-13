# sharpapi (R client)

R client for [SharpAPI](https://sharpapi.io), the real-time sports betting odds API: live odds from 45+ sportsbooks, no-vig fair odds, +EV and arbitrage detection.

```r
Sys.setenv(SHARPAPI_KEY = "your-key")   # free tier: https://sharpapi.io/pricing
odds <- sharpapi_odds(league = "mlb", market_type = "moneyline", limit = 500)
head(odds[order(-odds$odds_decimal), c("selection", "sportsbook", "odds_american")])
```

Status: skeleton pending CRAN polish and submission (see issues). MIT.
