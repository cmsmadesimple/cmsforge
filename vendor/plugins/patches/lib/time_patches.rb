class Time
  
  def last_week(day = :monday)
    days_into_week = { :monday => 0, :tuesday => 1, :wednesday => 2, :thursday => 3, :friday => 4, :saturday => 5, :sunday => 6}
    since(-1.week).beginning_of_week.since(days_into_week[day].day).change(:hour => 0)
  end
  
end
