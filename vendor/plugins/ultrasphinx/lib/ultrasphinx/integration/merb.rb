module Ultrasphinx
  ROOT = Merb.root
  ENV = (Merb.env == 'rake' ? 'development' : Merb.env)
end

puts 'loading plugin hooks'
Merb::Plugins.config[:ultrasphinx] = {}
Merb::Plugins.add_rakefiles "ultrasphinx/integration/merb_tasks"
