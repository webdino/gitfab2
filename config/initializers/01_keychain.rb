path = Rails.root.join 'config', 'keychain.yml'
KEYS = YAML.load(ERB.new(IO.read path).result)[Rails.env]
