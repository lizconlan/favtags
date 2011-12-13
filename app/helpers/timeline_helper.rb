module TimelineHelper
  def nav_range(current, max, bar_length=7)
    range = []
    
    if max <= bar_length
      for i in (max-bar_length..max)
        range << i unless i < 1
      end
    else
      if current < max - (bar_length-1)
        halfway = (bar_length-1)/2
        for i in (0..halfway-1)
          range << current + i
        end
        range << "..."
        for i in (1..halfway)
          range << max - ((bar_length-1)/2 - i)
        end
      else
        for i in (max-bar_length+1..max)
          range << i
        end
      end
    end
    
    range
  end
  
  def display_time(time, utc_offset)
    disp_time = time.dup
    disp_time = disp_time.in_time_zone(utc_offset.to_i/100)
    disp_time = disp_time.to_s(:display).gsub("AM", "am").gsub("PM", "pm")
    if disp_time =~ /, 0(\d:)/
      disp_time.gsub!(", 0#{$1}", ", #{$1}")
    end
    disp_time + " " + utc_offset
  end
end
