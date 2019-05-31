require "epathway_scraper"

scraper = EpathwayScraper::Scraper.new(
  "https://epathway.thehills.nsw.gov.au/ePathway/Production"
)

# Get the main page and ask for DAs
page = scraper.agent.get(scraper.base_url)

page = EpathwayScraper::Page::ListSelect.pick(page, :all)

# Search for the last 30 days is set by default
page = EpathwayScraper::Page::Search.click_search(page)

EpathwayScraper::Page::Index.scrape_all_index_pages_with_gets(nil, scraper.base_url, scraper.agent) do |record|
  EpathwayScraper.save(record)
end
