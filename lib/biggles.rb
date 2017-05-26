require 'biggles/version'
require 'biggles/job/oneshot.rb'
# Biggles is a simple job scheduler and manager based on ActiveRecord
module Biggles
  def self.hello(name)
    puts "hello #{name}"
  end
end
