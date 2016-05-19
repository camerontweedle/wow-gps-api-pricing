require 'net/http'
require 'open-uri'


BLIZZARD_API_KEY = ENV['blizzard_api_key']

namespace :init do

  # rake init:setup['us']
  # rake init:setup['eu']
  # rake init:setup['both'] - DEFAULT
  task :setup, [:region] => [:environment] do |t, args|
    region = args[:region].downcase unless args[:region].nil?
    if region == "us" or region == "eu"
      getRealms(region)
      Rake::Task['realms:enable'].reenable
      Rake::Task['realms:enable'].invoke(region)
      Rake::Task['realms:urls'].reenable
      Rake::Task['realms:urls'].invoke(region)
    else
      getRealms('us')
      getRealms('eu')
      Rake::Task['realms:enable'].reenable
      Rake::Task['realms:enable'].invoke('both')
      Rake::Task['realms:urls'].reenable
      Rake::Task['realms:urls'].invoke('both')
    end
  end
end


def getRealms(region)
  json = JSON.parse(open("https://#{region}.api.battle.net/wow/realm/status?locale=en_US&apikey=#{BLIZZARD_API_KEY}").read, symbolize_names: true)
  json[:realms].each do |realm|
    r = Realm.where(slug: realm[:slug], name: realm[:name], region: region, realm_type: realm[:type], population: realm[:population], source_realm: realm[:connected_realms][0]).first_or_create
  end
end
