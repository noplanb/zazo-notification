module Notification
  class UnknownNotification < StandardError
  end

  def self.find(name, prefix = nil)
    const_get [prefix, name].compact.map(&:to_s).map(&:camelize).join '::'
  rescue NameError
    raise UnknownNotification, "Notification #{name.inspect} not found"
  end

  def self.all
    Notification::Base.descendants.select { |klass| klass.name.starts_with?("#{name}::") }.sort_by(&:name)
  end
end
