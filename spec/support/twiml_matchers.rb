require 'rspec/expectations'

RSpec::Matchers.define :say_twiml_error do
  match do |actual|
    actual.match(/error/).present?
  end
end

RSpec::Matchers.define :say_twiml_verification_code do |expected|
  match do |actual|
    m = actual.scan(/\d/m)
    return false unless m
    digits = m.join('')
    digits.include?(expected)
  end

  failure_message do |actual|
    "expected that #{actual} says code #{expected.inspect}"
  end
end
