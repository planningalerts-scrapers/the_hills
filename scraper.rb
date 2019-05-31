require "epathway_scraper"

EpathwayScraper::Scraper.scrape_and_save(
  "https://epathway.thehills.nsw.gov.au/ePathway/Production",
  list_type: :last_30_days, with_gets: true
)
