require 'acts_as_historizable'
ActiveRecord::Base.send( :include, Fguillen::Acts::Historizable )
