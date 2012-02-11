require "nokogiri"
require "open-uri"
               
@base_url = "http://tracks4africa.co.za"
@ids_list = []
@sites = {}


def get_attributes_from_ids_list(ids_list=(149900..149904).to_a)
  ids_list.each do |id|
    begin 
      doc = Nokogiri::HTML(open("#{@base_url}/listings/item/w#{id}/"))
      @sites[id] = [extract_name(doc), extract_lon_lat(id)]
      # puts "ID #{id}   #{@sites[id][0]}, #{@sites[id][1]} (LatLon: #{@sites[id][1]},#{@sites[id][0]})"
    rescue 
      puts "ID #{id}   something broke - could be a 404" 
      next
    end
  end
  puts @sites
end

def extract_name(doc)
  doc.css("h2 .listing-detail-heading").text
end

def extract_lon_lat(id)
  doc = open ("#{@base_url}/listings/item/w#{id}/")
  doc.each do |line| 
    if line.match(/LonLat/) 
      then return line.scan(/\((.*?)\)/).first.first.split(',').map{|x|x.to_f}
    end
  end
end              

def get_next_search_page(page_url)

  doc = Nokogiri::HTML(open("#{@base_url}#{page_url}"))

  link = doc.css('#t4a-content a:nth-child(2)')

  if link.text == "Next"
    then link.first['href']                                                             
  else    
    "End"
  end        
end                     

def get_all_search_result_pages
  initial_url = "/listings/advanced_search/?csrfmiddlewaretoken=c5a8cffb6582ffaa050a0eb0b1993ec5&advanced_search=1&searching=1&offset=0&spatial_id=&search_text=&country=BW&region=Okavango%2FMoremi&city=&category=11&subcategory="
  
  @pages = [initial_url]

  while get_next_search_page(@pages.last) != "End"
    @pages << get_next_search_page(@pages.last)
  end

  puts "Done"
  @pages
    
end

get_attributes_from_ids_list