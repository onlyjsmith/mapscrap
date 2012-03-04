require "httparty"

class SearchForSite
  
  def start
    camps = []
    doc = File.open("camps.txt",'r') 
    doc.each_line do |line|
      name = line.split(', ')[1]
      short = name.split(' ')[0]
      camps << short
    end
    
    camps.each do |camp|
      check_exists(camp)
    end
  end

  def check_exists(camp)
    response = HTTParty.get(URI.escape("http://craigmills.cartodb.com/api/v1/sql?q=SELECT * FROM sites WHERE name ILIKE '%#{camp}%' LIMIT 5"))
    if response.parsed_response['total_rows'] == 0
      then puts "Nothing found for #{camp}"
    else puts "Found results for #{camp}"
    end
    
    # puts "Searched for #{camp}"
    #     puts "Found #{response}"
    #     puts "----"     
  end
  
  def update_as_ws(camp)
    response = HTTParty.get(URI.escape("http://craigmills.cartodb.com/api/v1/sql?q=SELECT * FROM sites WHERE name ILIKE '%#{camp}%' LIMIT 5"))
    
  end
  
end

s = SearchForSite.new
# @result = s.check_exists("kalamu")
s.start