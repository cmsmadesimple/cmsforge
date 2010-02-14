module ProjectHelper

  def letter_options
    $letter_options_list ||= ['0-9'].concat(("A".."Z").to_a)
  end

end
