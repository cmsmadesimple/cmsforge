
require "#{File.dirname(__FILE__)}/../test_helper_merb_dm"

class MdConfigureTest < Test::Unit::TestCase
  
  CONF = "#{Merb.root}/config/ultrasphinx/development.conf"
  
  def test_configuration_hasnt_changed  
    unless ENV['DB'] =~ /postgresql/i
      # MySQL only right now... not really a big deal

      File.delete CONF if File.exist? CONF
      Dir.chdir Merb.root do
        Ultrasphinx::Configure.run
      end
  
      @offset = 4
      @current = open(CONF).readlines[@offset..-1]
      @canonical = open(CONF + ".canonical").readlines[@offset..-1] 
      @canonical.each_with_index do |line, index|
         assert_equal line, @current[index], "line #{index}:#{line.inspect} is incorrect"
      end      
    end
  end

end