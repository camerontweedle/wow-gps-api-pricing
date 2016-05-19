WoW-GPS Pricing API
==

This application is designed to fetch Auction Data from the [Blizzard WoW API](https://dev.battle.net) and make historical data available via a "query-able" REST API. The API provides access to raw auction data, free from opinionated calculations, so it should be easily integrated into just about any 3rd party platform, although it's main purpose was to serve as a pricing backend for WoW-GPS

WoW-GPS Project
--
WoW-GPS is a 3rd party application designed to help provide tools and resources to aid in the efforts of gold-making in World of Warcraft &copy;
- Project Forum: (http://stormspire.net/official-wow-gps-forum/)
- WoW-GPS Data API: *still in development*
- WoW-GPS Front End: *still in development*

Dependencies
--
- **Webserver** - This application is intended to be run on either a public or private webserver, however a local installation should also be possible. The API was built and tested on linux/Ubuntu, but all of the Dependencies should be available to run on either iOS or Windows, with some fine tuning.

- **Ruby on Rails** - The Pricing API is built on Rails, so the installation steps will assume you have a working Ruby/Rails installation in order to progress. For setup instructions, please see (http://rubyonrails.org/)

- **Redis** - The API uses [sidekiq](https://github.com/mperham/sidekiq) for background job processing, which in turn uses Redis to manage the job queue, so some form of Redis server will need to be made available to the API application. The redis server CAN be run locally, and should be pretty straightforward on both Linux or iOS. For Windows installations, you might have to play around with things a bit more to get it running, see the redis page for more information (http://redis.io/). **NOTE**: if you're not running the default, local Redis configuration/ports, some additional configuration will need to be made. Please review the [sidekiq wiki](https://github.com/mperham/sidekiq/wiki/Using-Redis) for instructions.

- **Database** - In order to optimize the bulk INSERT/UPDATE statements of the tens of thousands of auctions for each realm, some manual SQL has been used. In order to ensure compatibility, Postgresql 9.5 or higher is required for support of the `INSERT INTO ... ON CONFLICT` syntax. To my knowledge, MySQL should also support this single-query syntax, but it's possible some slight adjustments will be required.

Installation/Setup
--
    git clone https://github.com/camerontweedle/wow-gps-api-pricing.git
    cd wow-gps-api-pricing
    bundle install

To setup the DB, from the application root directory:

    rake db:setup
    rake db:migrate

The application requires 2 ENVIRONMENT variables, served to rails via the [figaro gem](https://github.com/laserlemon/figaro). You will need to create a file at `config/application.yml` with the following fields:
- blizzard_api_key: paste your API key, as generated via (https://dev.battle.net). The application only makes limited use of the Blizzard API endpoints, as the auction dump files are stored at static URLs, however, a Blizzard API key is required in order to generate the initial realm information as well and fetch the Auction URL for each realm.
- auction_delete_timeframe: the number of hours to store auction information in the database for. Any auctions created beyond this value will be completely removed from the DB, hourly. For example, set to "168" to keep auction data for 1 week, etc.

Rake Commands
--
The main initialization/configuration has all been made available via rake tasks.

Setup Tasks - this will query the Blizzard API for a list of realms and then add each of them to the DB, followed by fetching the auction data URL for each realm. This can take a few minutes to complete for ALL realms.

    rake init:setup['both']
    rake init:setup['us']
    rake init:setup['eu']

*Note*: `rake init:setup` will default to 'both', so you can simply run that if you'd like to initialize all realms.

Realm Tasks - used to either Enable/Disable realms/regions or to re-fetch the Auction URLs from the Blizzard API

    rake realms:enable['both']
    rake realms:enable['us']
    rake realms:enable['eu']
    rake realms:enable['emerald-dream@us']

    rake realms:disable['both']
    rake realms:disable['us']
    rake realms:disable['eu']
    rake realms:disable['emerald-dream@us']

    rake realms:urls['both']
    rake realms:urls['us']
    rake realms:urls['eu']
    rake realms:urls['emerald-dream@us']

*Note*: Again, all tasks default to 'both', so if you want to run the task for all realms, feel free to omit the parameter.

*Note*: The `rake init:setup` task automatically calls the `realms:enable` and 'realms:urls' task with the appropriate parameters, so you really only need to use the `realms` tasks if you need to make post-setup changes, or if you notice that a certain realm(s) aren't fetching data and suspect the URL might have changed. (which, to my knowledge, has only occurred once in the history or the Blizzard API, when they moved servers)

Sidekiq Runner
--
Sidekiq is a multi-threaded job processer, which means that you should really only have to run once instance of it to handle all of the jobs. The API application has been setup with 3 distinct queues:
- default: this queue handles the Realm Status Job, which scans all enabled realm URLs to see if the Last-Modified header has changed. This job runs every 30 mins.
- auctions: this queue processes the Blizzard API Job, which pulls down new data from the Auction URL and INSERTS/UPDATES the DB. This job will be queued whenever the Realm Status Job finds any new data.
- delete: based on the 'auction_delete_timeframe' ENV variable, this queue processes the Delete Auctions Job every 55 mins, removing any auctions that were created beyond the timeframe specified.

On initialization, the application will clear out the Redis store of any lingering jobs and automatically queue up the Realm Status and Delete Auctions Jobs. To run the sidekiq worker:

    sidekiq -C config/sidekiq.yml

Running/Querying the API
--
In order to access the data via the API endpoints, you'll need to have a webserver running the application. This can easily be achieved locally by running:

    rails server

or, simply

    rails s

This will boot the application using the Puma webserver and will be accessible by default at port 8000, via `http://localhost:8000`

If you're running the application on a Private or Public server, instead, you might prefer to use something like Apache or Nginx as a reverse proxy, to instead make the API available via a custom domain. I'm not going to cover the specifics of that here, as there are many possible configurations, so I'll assume you have some prior knowledge on this subject and let you and google help each other out.

Once running, the API has 2 endpoints:
 - `/api/auctions/items/:item_id` which returns ALL auctions for the specified Item ID and accepts the following parameters:
  - `region` - either `?region=us` or `?region=eu`
  - `realm` - the slug of a specific realm. If you specify a realm, you'll also need to specify a region, such as `?region=us&realm=emerald-dream` or `?region=eu&realm=emerald-dream`
  - `period` - the number of hours to include auctions for. IE. `?period=24` for the past day, or `?period=168` for the past week
 - `/api/auctions/realm/:region/:slug` which accepts the `period` parameter and functions the same way as with the Items endpoint. The realm endpoint will return ALL auctions for ALL items for the specified realm

So, assuming you're querying a local webserver, if you wanted to fetch data for item 12345 for US-Emerald Dream for the past 2 days, you'd issue a GET request to

    http://localhost:8000/api/auctions/items/12345?region=us&realm=emerald-dream&period=48

If you wanted to fetch ALL auction from US-Emerald Dream for the past week, you'd issue a GET request to

    http://localhost:8000/api/auctions/realm/us/emerald-dream?period=168


To-Do
--
- Finish API integration tests. I still need to add tests for invalid requests, etc.
- ActiveJob tests - This was my first time integrating my job queue directly into Rails' ActiveJob, so I was more concerned with getting it working than with testing best practices, so I'll need to take a look into that, still.

Copyright/License
--
World of Warcraft is a registered trademark of Blizzard Entertainment, Inc. This application source is distributed under the [MIT License](https://opensource.org/licenses/MIT).
