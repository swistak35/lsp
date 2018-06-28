$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lsp'

require 'timeout'

RSpec.configure do |config|
  config.around(:each) do |example|
    timeout = example.metadata[:timeout] || 5
    Timeout.timeout(timeout, &example)
  end
end
