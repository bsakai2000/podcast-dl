require 'net/http'
require 'rss'

def get_cached_feed(uri, etag=nil, last_modified=nil)
  if uri.nil?
    return nil
  elsif uri.kind_of?(URI)
    # This is already a URI, nothing to do
  elsif uri.respond_to?(:to_str)
    uri = URI(uri.to_str)
  else
    raise 'Parameter uri could not be converted to URI'
  end
  # By now, uri must be of type URI
  
  response = Net::HTTP.get_response(
    uri,
    (etag.nil? ? {} : {
      'If-None-Match' => etag
    }).merge(last_modified.nil? ? {} : {
      'If-Modified-Since' => last_modified
    }),
  )
  code = Integer(response.code)
  if code == 304
    return nil, etag, last_modified
  elsif code.between?(199, 301)
    return response.body, response['ETag'], response['Last-Modified']
  else
    raise "Could not get URI with code #{response.code} (#{response.body})"
  end
end

def download_file(uri, filename)
  filename.sub!('/', '_')
  if File.exist?(filename)
    puts "Already have #{filename}"
    return false
  end

  if uri.nil?
    return false
  elsif uri.kind_of?(URI)
    # This is already a URI, nothing to do
  elsif uri.respond_to?(:to_str)
    uri = URI(uri.to_str)
  end

  response = Net::HTTP.get_response(uri)
  case response
  when Net::HTTPSuccess then
  open(filename, 'w') do |fh|
    fh.write(response.body)
  end
  puts "Downloaded #{uri} to #{filename}"
  when Net::HTTPRedirection then
    download_file(
      response['location'],
      filename
    )
  else
    raise "Could not get URI with code #{response.code} (#{response.body})"
  end

  return true
end

def retag_metadata(item, filename)
  puts "Resetting date to #{item.pubDate.iso8601[..18]}"
  # We need to do this in two calls, because for some reason trying to modify
  # the recording date while retagging from v2.3 to v2.4 causes the tag version
  # to update without changing the recording date
  system(
    'eyeD3',
    '--to-v2.4',
    filename
  )
  system(
    'eyeD3',
    '--recording-date', item.pubDate.iso8601[..18],
    filename
  )
end

def parse_feed(rss)
  original_cwd = Dir.pwd
  document = RSS::Parser.parse(rss)

  # Create the enclosing directory if it's not yet present
  Dir.mkdir(document.channel.title) unless File.exist?(document.channel.title)
  Dir.chdir(Dir.pwd+'/'+document.channel.title)

  download_file(document.channel.image.url, 'cover.jpg')
  document.items.each do |item|
    filename = "#{item.pubDate.iso8601[..9]} #{item.title}.mp3"
    if download_file(
        item.enclosure.url,
        filename
    )
      retag_metadata(item, filename)
    end
  end
  Dir.chdir(original_cwd)
end
