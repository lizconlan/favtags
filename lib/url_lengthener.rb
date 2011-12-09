class UrlLengthener
  def self.expand_url url
    bounces = 0 #not currently reported, but could be useful, maybe?!
    response = ping_url(url)
    while response[:moved] == true
      bounces += 1
      response = ping_url(response[:location])
    end
    return response[:location]
  end
  
  private
    def self.ping_url url
      parts = URI.parse(url)
      if parts.host == "youtu.be"
        #won't get much more sensible, just longer - return as-is
        return {:moved => false, :location => url}
      end
      if parts.host.length > 8 and parts.host != "tinyurl.com"
        #probably not intended as a shortener then - return as-is
        return {:moved => false, :location => url}
      end
      req = Net::HTTP.new(parts.host, parts.port)
      header = req.head(parts.path)
      case header.code 
        when /30?/
          if header.get_fields("location").first == url
            return {:moved => false, :location => url}
          else
            return {:moved => true, :location => header.get_fields("location").first}
          end
        else
          return {:moved => false, :location => url}
      end
    end
end