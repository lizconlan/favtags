class UrlLengthener
  #vanity shorteners that only ever point back to their own site - if you see one of these, you already know what you're in for
  EXEMPTIONS = ["bbc.in", "youtu.be", "flic.kr", "pic.twitter.com", "instagr.am", "econ.st", "lnkd.in", "tcrn.ch", "wpo.st", "on.wsj.com", "thetim.es", "ti.me", "tgr.ph", "slidesha.re", "seati.ms", "reut.rs", "nzh.tw", "nzh.tw", "nym.ag", "nyob.co", "nyti.ms", "lat.ms", "itv.co", "itun.es", "ind.pn", "huff.to", "gu.com", "gr.pn", "gaw.kr", "f24.my", "fxn.ws", "4sq.com", "onforb.es", "arst.ch"]
  
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
      begin
        parts = URI.parse(url.gsub(" ", "%20"))
      rescue
        #return straight away if there's a problem with the url
        return {:moved => false, :location => url}
      end
      
      #return straight away if there's no host part
      return {:moved => false, :location => url} if parts.host.nil? or parts.host.empty?
      
      if EXEMPTIONS.include?(parts.host)
        #won't get much more sensible, just longer - return as-is
        return {:moved => false, :location => url}
      end
      
      if parts.host.length > 8 and parts.host != "tinyurl.com"
        #probably not intended as a shortener then - return as-is
        return {:moved => false, :location => url}
      end
      req = Net::HTTP.new(parts.host, parts.port)
      if parts.path.empty?
        header = req.head("/")
      else
        begin
          header = req.head(parts.path)
        rescue
          return {:moved => false, :location => url} #argh, it's all gone wrong - put the original back
        end
      end
      return {:moved => false, :location => url} unless header.get_fields("location") #error occured somewhere, give me back my url
      if header.get_fields("location").first[0..0] == "/"
        #in-site redirection with relative url, return the original
        return {:moved => false, :location => url}
      end
      case header.code 
        when /30?/
          if header.get_fields("location").first == url
            return {:moved => false, :location => url}
          else
            if parts.host == "t.co" and header.get_fields("location").first =~ /^http:\/\/twitter.com\/[^\/]*\/status\/[0-9]*\/photo/
              return {:moved => false, :location => "http://pic.twitter.com#{parts.path}"}
            else
              return {:moved => true, :location => header.get_fields("location").first}
            end
          end
        else
          return {:moved => false, :location => url}
      end
    end
end