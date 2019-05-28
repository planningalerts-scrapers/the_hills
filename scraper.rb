require "epathway_scraper"

scraper = EpathwayScraper::Scraper.new(
  "https://epathway.thehills.nsw.gov.au/ePathway/Production"
)

agent = scraper.agent
enquiry_url = "https://epathway.thehills.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx"

# Get the main page and ask for DAs
page = agent.get(enquiry_url)
form = page.forms.first
form.radiobuttons[0].click
page = form.submit(form.button_with(:value => /Next/))

# Search for the last 30 days
form = page.forms.first
form.radiobuttons.last.click
page = form.submit(form.button_with(:value => /Search/))

page_label = page.at('#ctl00_MainBodyContent_mPagingControl_pageNumberLabel')
if page_label.nil?
  # If we can't find the label assume there is only one page of results
  number_of_pages = 1
elsif page_label.inner_text =~ /Page \d+ of (\d+)/
  number_of_pages = $~[1].to_i
else
  raise "Unexpected form for number of pages"
end

puts "Found #{number_of_pages} pages of development applications"

(1..number_of_pages).each do |page_no|
  puts "Scraping page #{page_no}"
  # Don't refetch the first page
  if page_no > 1
    page = agent.get("https://epathway.thehills.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquirySummaryView.aspx?PageNumber=#{page_no}")
  end

  # Extract applications
  table = page.at('table.ContentPanel')
  scraper.extract_table_data_and_urls(table).each do |row|
    data = scraper.extract_index_data(row)

    record = {
      "date_received" =>     data[:date_received],
      "council_reference" => data[:council_reference],
      "description" =>       data[:description],
      "address" =>           data[:address],
      "info_url" =>          enquiry_url,
      "date_scraped" =>      Date.today.to_s
    }
    EpathwayScraper.save(record)
  end
end
