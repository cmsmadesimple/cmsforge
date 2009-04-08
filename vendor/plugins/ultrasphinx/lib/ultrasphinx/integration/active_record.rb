module Ultrasphinx::ActiveRecordExtensions
  def set_distance(dist)
    @attributes['distance'] = dist
  end
end

class ActiveRecord::Base
  include Ultrasphinx::ActiveRecordExtensions

  extend Ultrasphinx::IsIndexed
end
class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def get_facets(*args)
    execute(*args)
  end
end