# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #include TagsHelper

  def tag_cloud(active, tags, classes)
  		if !active then return end
  		max, min = 0, 0
  		unless tags.empty?
  			#tags.sort! {|x,y| y.count <=> x.count}
  			max = tags.first.count
  			min = tags.last.count			
  		end

  		divisor = ((max - min) / classes.size) + 1

  		tags.each { |t|
  			  yield t.name, t.id, classes[(t.count.to_i - min) / divisor]
  		}
  	end

end
