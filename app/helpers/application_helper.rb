module ApplicationHelper
  def tag_cloud(active, tags, classes)
    if !active then return end
    max, min = 0, 0
    unless tags.empty?
      sorted_tags = tags.sort {|x,y| y.count <=> x.count}
      max = sorted_tags.first.count
      min = sorted_tags.last.count
    end

    divisor = ((max - min) / classes.size) + 1
    if divisor == 0
      divisor = 1
    end

    tags.each { |t|
      yield t.name, t.id, classes[(t.count.to_i - min) / divisor]
    }
  end

  def nl2br(string)
    string.gsub("\n\r","<br>").gsub("\r", "").gsub("\n", "<br />")
  end

  # options
  # :start_date, sets the time to measure against, defaults to now
  # :date_format, used with <tt>to_formatted_s<tt>, default to :default
  def timeago(time, options = {})
    start_date = options.delete(:start_date) || Time.new
    date_format = options.delete(:date_format) || :default
    delta_minutes = (start_date.to_i - time.to_i).floor / 60
    #if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
    distance = distance_of_time_in_words(delta_minutes);
    if delta_minutes < 0
      "#{distance} from now"
    else
      "#{distance} ago"
    end
    #else
    #  return "on #{system_date.to_formatted_s(date_format)}"
    #end
  end

  def distance_of_time_in_words(minutes)
    case
    when minutes < 1
      "less than a minute"
    when minutes < 50
      pluralize(minutes, "minute")
    when minutes < 90
      "about one hour"
    when minutes < 1080
      "#{(minutes / 60).round} hours"
    when minutes < 1440
      "one day"
    when minutes < 2880
      "about one day"
    when minutes < (60 * 24 * 30)
      "#{(minutes / 1440).round} days"
    when minutes < (60 * 24 * 30 * 1.5)
      "about one month"
    else
      "#{(minutes / 1440 / 30).round} months"
    end
  end
end
