Time::DATE_FORMATS.merge!(:twitter => lambda { |time| time.strftime "%a %b %d %Y - %H:%M:%S"})