# clear redisDB and queue up the first Scan

Sidekiq.redis { |conn| conn.flushdb }
RealmStatusJob.perform_later
DeleteAuctionsJob.perform_later
