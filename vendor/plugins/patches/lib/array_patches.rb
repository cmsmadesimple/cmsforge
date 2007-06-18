class Array
  
  def first
    if self.size > 0
      self[0]
    end
  end
  
  def second
    if self.size > 1
      self[1]
    end
  end
  
  # If +number+ is greater than the size of the array, the method
  # will simply return the array itself sorted randomly
  def randomly_pick(number = 1)
    sort_by{ rand }.slice(0...number)
  end

end
