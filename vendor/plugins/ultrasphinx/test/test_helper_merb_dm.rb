
require 'rubygems'
require 'test/unit'
require 'echoe'

Echoe.silence do
  HERE = File.expand_path(File.dirname(__FILE__))
  $LOAD_PATH << HERE
  LOG = "#{HERE}/integration_merb_dm/app/log/development.log"     
end

require 'merb-core'
Merb::Config.setup({})
Merb.environment = Merb::Config[:environment]
Merb.root = "#{HERE}/integration_merb_dm/app"
Merb::BootLoader.run

#Dir.chdir "#{HERE}/integration/app" do
#  system("rake us:start")
#end
