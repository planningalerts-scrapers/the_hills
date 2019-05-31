require "epathway_scraper"

scraper = EpathwayScraper::Scraper.new(
  "https://epathway.thehills.nsw.gov.au/ePathway/Production"
)

# Get the main page and ask for DAs
page = scraper.agent.get(scraper.base_url)
page = EpathwayScraper::Page::ListSelect.follow_javascript_redirect(page, scraper.agent)

page = EpathwayScraper::Page::ListSelect.pick(page, :all)

page = EpathwayScraper::Page::Search.pick(page, :last_30_days, scraper.agent)

EpathwayScraper::Page::Index.scrape_all_index_pages_with_gets(nil, scraper.base_url, scraper.agent) do |record|
  EpathwayScraper.save(record)
end
