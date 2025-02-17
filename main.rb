require_relative './config'
require_relative './rss'

config = load_config

Dir.chdir(config['directory'])

config['feeds'].each do |feed|
  puts feed['name']
  body, feed['etag'], feed['lastModified'] = get_cached_feed(
    feed['url'],
    feed['etag'],
    feed['lastModified']
  )
  if not body.nil?
    parse_feed(body)
  else
    puts 'Feed already up to date'
  end
end

write_config(config)
