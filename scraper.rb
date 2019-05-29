require "epathway_scraper"

scraper = EpathwayScraper::Scraper.new(
  "https://epathway.thehills.nsw.gov.au/ePathway/Production"
)

agent = scraper.agent
enquiry_url = "https://epathway.thehills.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx"

# Get the main page and ask for DAs
page = agent.get(scraper.base_url)
form = page.forms.first
form.radiobuttons[0].click
page = form.submit(form.button_with(:value => /Next/))

# Search for the last 30 days
form = page.forms.first
form.radiobuttons.last.click
page = form.submit(form.button_with(:value => /Search/))

number_of_pages = scraper.extract_total_number_of_pages(page)

puts "Found #{number_of_pages} pages of development applications"

(1..number_of_pages).each do |page_no|
  puts "Scraping page #{page_no}"
  # Don't refetch the first page
  if page_no > 1
    page = agent.get("https://epathway.thehills.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquirySummaryView.aspx?PageNumber=#{page_no}")
  end

  scraper.scrape_index_page(page) do |record|
    EpathwayScraper.save(record)
  end
end
