Time::DATE_FORMATS.merge!(:twitter => lambda { |time| time.strftime "%a %b %e %Y - %H:%M:%S"})
Time::DATE_FORMATS.merge!(:display => lambda { |time| time.strftime "%e %b %Y, %I:%M%p"})