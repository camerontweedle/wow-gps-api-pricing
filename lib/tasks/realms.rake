require 'net/http'
require 'open-uri'

namespace :realms do

  # rake realms:enable['us']
  # rake realms:enable['eu']
  # rake realms:enable['realm-slug@region']
  # rake realms:enable['both'] - DEFAULT
  task :enable, [:realm] => [:environment] do |t, args|
    changeRealmStatus(args[:realm], "enabled")
  end

  # rake realms:disable['us']
  # rake realms:disable['eu']
  # rake realms:disable['realm-slug@region']
  # rake realms:disable['both'] - DEFAULT
  task :disable, [:realm] => [:environment] do |t, args|
    changeRealmStatus(args[:realm], "disabled")
  end

  # rake realms:urls['us']
  # rake realms:urls['eu']
  # rake realms:urls['realm-slug@region']
  # rake realms:urls['both'] - DEFAULT
  task :urls, [:realm] => [:environment] do |t, args|
    realms = filterRealm(args[:realm])
    realms.each do |realm|
      realm.getRealmURL
    end
  end
end

def changeRealmStatus(param, status)
  realms = filterRealm(param)
  realms.each do |realm|
    realm.status = status
    realm.save
  end
end

def filterRealm(param)
  return case param
  when nil, "both" then Realm.all
  when "us", "eu" then Realm.where(region: param)
  else
    params = param.split("@")
    Realm.where(slug: params[0], region: params[1])
  end
end
