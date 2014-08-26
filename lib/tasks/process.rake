require 'modules/batch_update.rb'
include BatchUpdate

task :scrape => :environment do
  BatchUpdate.scrape
end

task :email => :environment do
  BatchUpdate.email
end
