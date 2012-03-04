require "nokogiri"
require "open-uri"
require './details' 

               
# @base_url is set in 'details.rb'
@sites = []

def get_related_result_pages(initial_url)
  pages = [initial_url]

  until get_next_link(pages.last) == "End"
    pages << get_next_link(pages.last)
  end

  puts "Done - got all search result pages"
  pages
end  

def get_next_link(page_url)
  doc = Nokogiri::HTML(open("#{@base_url}#{page_url}"))
  links = doc.css('a')
  next_link = "End"
  links.each do |link_item|
    if link_item.text.strip.downcase == "next"
      then next_link = link_item['href']
    end
  end
  next_link
end  

def get_ids_from_page(page_url)
  # The page needs to come from a filtered search, i.e. 'country' and 'type', rather than free search
  ids = []
  doc = Nokogiri::HTML(open("#{@base_url}#{page_url}"))
  listings = doc.css(".search-result-item-content")
  listings.each do |listing|
    new_id = listing.children[4].text.strip.scan(/\w(.+)/).first.first.to_i  
    puts new_id
    ids << new_id
  end      
  ids
end

def get_attributes_from_pages(pages)
  # sites = []
  pages.each do |page_url|
    ids = get_ids_from_page(page_url)
    # sites << get_attributes_from_ids_list(ids)
    get_attributes_from_ids_list(ids)
  end       
  # sites
end    

def get_attributes_from_ids_list(ids_list=(149900..149904).to_a)
  sites = []
  ids_list.each do |id|
    begin 
      doc = Nokogiri::HTML(open("#{@base_url}/listings/item/w#{id}/"))
      puts "Getting site ##{id}..."   
      coords = extract_lon_lat(id) 
      puts coords
      @sites << [id, extract_name(doc), coords[:lon], coords[:lat]]
      # puts "#{sites[id]}"
    rescue 
      puts "ID #{id}   something broke - could be a 404" 
      next
    end               
  # puts "sleeping....."
  # sleep(5)
  end
  sites
end

def extract_name(doc)
  doc.css("h2 .listing-detail-heading").text.gsub(/\,/,"")
end

def extract_lon_lat(id)
  lon_lat = {}
  doc = open ("#{@base_url}/listings/item/w#{id}/")
  doc.each do |line| 
    if line.match(/LonLat/) 
      then 
      lon_lat[:lon] = line.scan(/\((.*?)\)/).first.first.split(',').first.to_f
      lon_lat[:lat] = line.scan(/\((.*?)\)/).first.first.split(',').last.to_f
      return lon_lat
    end
  end
end              

def write_csv(data)
  doc = File.open('sites.csv', 'w')
  data.each do |record|
    doc << "#{record[0]},#{record[1]},#{record[2]},#{record[3]}\n"
  end
  doc.close          
end

def do_it_all(page_url) 
  # The page needs to come from a filtered search, i.e. 'country' and 'type', rather than free search
  pages_to_parse = get_related_result_pages(page_url)
  get_attributes_from_pages(pages_to_parse)
  write_csv(@sites)
  @sites
end                                                                         


# AllSites.do_it_all ARGV[0] 

# URL for 62 lodges in Delta "/listings/advanced_search/?csrfmiddlewaretoken=c5a8cffb6582ffaa050a0eb0b1993ec5&advanced_search=1&searching=1&offset=0&spatial_id=&search_text=&country=BW&region=Okavango%2FMoremi&city=&category=11&subcategory="

# URL for 3 hotels in Delta "/listings/advanced_search/?csrfmiddlewaretoken=c5a8cffb6582ffaa050a0eb0b1993ec5&advanced_search=1&searching=1&offset=0&spatial_id=&search_text=&country=BW&region=Okavango%2FMoremi&city=&category=11&subcategory=296"