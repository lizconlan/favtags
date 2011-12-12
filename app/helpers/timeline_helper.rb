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
end
