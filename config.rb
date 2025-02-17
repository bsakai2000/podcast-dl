require 'json'

CONF_FILE = "#{ENV['HOME']}/.config/podcast-dl.json"

def load_config
  config = nil
  open(CONF_FILE, 'r') do |fh|
    config = JSON::load(fh)
  end
  return config
end

def write_config(config)
  open(CONF_FILE, 'w') do |fh|
    fh.write(
      JSON::pretty_generate(
        config
      )
    )
    fh.write("\n")
  end
end
