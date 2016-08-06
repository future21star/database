require 'csv'
require 'watir-webdriver'
require 'watir-scroll'

require_relative 'lib/linkedin_common'
require_relative 'lib/wait_functions'

require_relative 'data/company_data'

# To run:
#   Install rvm, ruby, etc.
#   `gem install bundler`
#   `bundle install`
#   `irb`
#     load 'person-scrape.rb'

def scrape_people
  people = []
  lis = @browser.lis(css: ".mod.result.people")
  lis.each do |li|
    user_id = li.attribute_value("data-li-entity-id")

    bd = li.div(class: "bd")
    name = bd.h3.a.text
    if name =~ /linkedin member/i
      next
    end

    if bd.dl(class: "snippet").present?
      title = bd.dl(class: "snippet").dd.p.text
    else
      title = bd.div.text
    end

    full_url = bd.h3.a.href
    person = {
      user_id: user_id,
      name: name,
      full_url: full_url,
      title: title
    }
    people << person
  end
  people
end

PROCESS_SIZE_1_10 = [1, "\"Compliance officer\" OR CCO OR CEO OR Owner OR Partner", ["(?=.*compliance)(?=.*officer)", "cco", "ceo", "owner", "partner"]]
PROCESS_SIZE_11_50 = [2, "\"Compliance officer\" OR CCO OR CEO OR Owner OR Partner", ["(?=.*compliance)(?=.*officer)", "cco", "ceo", "owner", "partner"]]
PROCESS_SIZE_51_200 = [3, "\"Compliance officer\" OR CCO OR CEO OR Owner OR Partner", ["(?=.*compliance)(?=.*officer)", "cco", "ceo", "owner", "partner"]]
PROCESS_SIZE_201_500 = [5, "\"Learning & Development\" OR \"Learning and Development\" OR \"Education & Training\" OR \"Education and Training\" OR (Compliance AND chief) OR CCO OR (compliance AND president) OR (compliance AND director)", ["(?=.*learning)(?=.*development)", "(?=.*education)(?=.*training)", "(?=.*compliance)(?=.*chief)", "cco", "(?=.*compliance)(?=.*president)", "(?=.*compliance)(?=.*director)"]]
PROCESS_SIZE_501_1000 = [7, "\"Learning & Development\" OR \"Learning and Development\" OR \"Education & Training\" OR \"Education and Training\" OR (Compliance AND chief) OR CCO OR (compliance AND president) OR (compliance AND director)", ["(?=.*learning)(?=.*development)", "(?=.*education)(?=.*training)", "(?=.*compliance)(?=.*chief)", "cco", "(?=.*compliance)(?=.*president)", "(?=.*compliance)(?=.*director)"]]

COMPANY_URLS = data_company_urls

initialize_browser
# random_wait_medium
# random_wait_medium


timestamp = Time.now.to_i
urls = data_urls

CSV.open("output/csvs-persons-#{timestamp}.csv", "w") do |csv|
  data_urls.each do |url|
    @browser.goto url
    random_wait_medium
    random_wait_medium
    random_wait_medium

    
    if @browser.text.include? "Restricted Location"
      next
    end
    
    div_tag = @browser.element(:class => "contest-entry-fee-container")
    @browser.scroll.to div_tag
    # element = @browser.tbody(class: "player-list-vs-repeat-container")

    # # el = driver.find_elements(:css, "div.otherprojects-item > div > a")
    # # p el[1].text #=> "Wiktionary"
    # # driver.action.move_to(el[1]).perform
    # # el = @browser.find_element(:css, "tbody.player-list-vs-repeat-container > tr > td")
    # # p el[1].text #=> "2B"
    # # @browser.action.move_to(el[1]).perform
    
    # #while(1)
    # element.scrollIntoView({block: "end", behavior: "smooth"});
    # element.location_once_scrolled_into_view
    #  random_wait_medium
    #end
#      puts tr.text
#    end
  end
end
# puts "Sign in to LeadIQ and select list for contacts, then hit <enter>"
# gets

# @linkedin_window = @browser.windows.first
# # @leadiq_window = @browser.windows.last

# timestamp = Time.now.to_i
# CSV.open("output/csvs-persons-#{timestamp}.csv", "w") do |csv|
#   COMPANY_URLS.each do |company_url|
#     @linkedin_window.use
#     @browser.goto company_url
#     random_wait_medium

#     div_how_connected = @browser.div(class: "how-connected")
#     if !div_how_connected.present?
#       next
#     end

#     num_employees = div_how_connected.as(class: "density").last.text.to_i
#     if num_employees > 1000
#       next
#     elsif num_employees > 500
#       process = PROCESS_SIZE_501_1000
#     elsif num_employees > 200
#       process = PROCESS_SIZE_201_500
#     elsif num_employees > 50
#       process = PROCESS_SIZE_51_200
#     elsif num_employees > 10
#       process = PROCESS_SIZE_11_50
#     else
#       process = PROCESS_SIZE_1_10
#     end

#     div_how_connected.a(class: "more").click
#     random_wait_medium

#     people = []
#     (max_people, title_search_query, match_titles) = process

#     @browser.a(class: "advs-link mod").click
#     random_wait_tiny
#     @browser.text_field(id: "advs-title").set(title_search_query)
#     random_wait_tiny
#     @browser.button(name: 'submit').click
#     random_wait_medium

#     if @browser.h3(class: "no-results-message").present?
#       next
#     end

#     chosen_people = []
#     scraped_people = scrape_people

#     match_titles.each do |match_title|
#       number_to_add = max_people - chosen_people.length
#       matched_people = scraped_people.select do |person|
#         regex = Regexp.new(match_title, Regexp::IGNORECASE)
#         (person[:title] =~ regex)
#       end
#       next if matched_people.nil?
#       concat_people = matched_people[0, number_to_add]
#       chosen_people.concat(concat_people)
#       concat_people.each do |concat_person|
#         scraped_people.delete(concat_person)
#       end
#     end

#     number_to_add = max_people - chosen_people.length
#     chosen_people.concat(scraped_people[0, number_to_add])

#     people = people.concat(chosen_people)

#     people.each do |person|
#       @linkedin_window.use
#       @browser.goto person[:full_url]
#       random_wait_medium()

#       url = @browser.url.split('?')[0]
#       person[:url] = url

#       scraped_name = person[:name]
#       scraped_url = person[:url]
#       scraped_title = person[:title]

#       result = [company_url, scraped_name, scraped_url, scraped_title]
#       puts result.join(", ")
#       csv << result

#       # @leadiq_window.use
#       # add_button = @browser.i(css: ".button.btn-add.fa.fa-plus")
#       # add_button.click
#       #
#       # puts "Added to LeadIQ: #{url}"
#     end
#   end
# end
