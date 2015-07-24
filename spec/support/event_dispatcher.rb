RSpec.configure do |config|
  config.around(event_dispatcher: false) do |example|
    EventDispatcher.with_state(false) { example.run }
  end

  config.around(event_dispatcher: true) do |example|
    EventDispatcher.with_state(true) { example.run }
  end
end
