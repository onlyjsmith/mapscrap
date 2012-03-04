require "httparty"

class SearchForSite
  
  def start
    camps = []
    doc = File.open("camps.txt",'r') 
    doc.each_line do |line|
      camps << line.split(', ')[1]
    end
    
    camps.each do |camp|
      check_exists(camp)
    end
  end

  def check_exists(camp)
    response = HTTParty.get(URI.escape("http://craigmills.cartodb.com/api/v1/sql?q=SELECT * FROM sites WHERE name ILIKE '%#{camp}%'"))
    puts "Searched for #{camp}"
    puts "Found #{response}"
    puts "----"
  end
  
end

s = SearchForSite.new
s.start