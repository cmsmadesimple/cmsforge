class Hash

  # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
  def except(*keys)
    self.reject { |k,v|
      keys.include? k.to_sym
    }
  end

  # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
  def only(*keys)
    self.dup.reject { |k,v|
      !keys.include? k.to_sym
    }
  end
  
  def to_sql
    sql = keys.sort {|a,b| a.to_s<=>b.to_s}.inject([[]]) do |arr, key|
      unless key.nil?
        arr[0] << "#{key} #{self[key] =~ /\%/ ? "LIKE" : "="} ?"
        arr << self[key]
      end
    end
    [sql[0].join(' AND ')] + sql[1..-1]
  end
  
  def to_sql_filter
    sql = keys.sort {|a,b| a.to_s<=>b.to_s}.inject([[]]) do |arr, key|
      unless key.nil? or self[key] == ''
        if key.index('like_') == 0
          newkey = key[5..-1]
          arr[0] << "#{newkey} LIKE ?"
          if self[key].include?('*')
            arr << self[key].gsub('*', '%')
          else
            arr << '%' + self[key] + '%'
          end
        else
          arr[0] << "#{key} #{self[key] =~ /\%/ ? "LIKE" : "="} ?"
          arr << self[key]
        end
      end
      arr
    end
    unless sql.nil? or sql.empty? or sql[0].empty?
      [sql[0].join(' AND ')] + sql[1..-1]
    else
      ['1 = 1']
    end
  end

end
