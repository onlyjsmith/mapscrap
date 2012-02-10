require "open-uri"

def do_it
  ids_list = (149900..149910).to_a

  @sites = {}

  ids_list.each do |id|
    begin 
      extract_lon_lat(id)
      puts "#{id} - #{@sites[id]}"
    rescue 
      puts "#{id} - something broke - could be a 404" 
      next
    end
  end  
end

def extract_lon_lat(id)
  doc = open("http://tracks4africa.co.za/listings/item/w#{id}/") 
  doc.each do |line| 
    if line.match(/LonLat/) 
      then 
      lon_lat = line.scan(/\((.*?)\)/).first.first.split(',')
      @sites[id] = lon_lat
    end
  end
end                              



do_it