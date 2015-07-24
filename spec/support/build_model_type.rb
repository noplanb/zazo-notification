# config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
# ActiveRecord::Base.establish_connection(config['test'])

module BuildModelTable
  def self.build_model_table(model, columns = {})
    table_name = model.table_name
    Rails.logger.info "Creating table #{table_name}"
    ActiveRecord::Base.connection.create_table table_name, force: true do |table|
      columns.each do |key, type|
        Rails.logger.info "creating column #{key.inspect} with type #{type.inspect}"
        table.column key, type
      end
    end
  end
end

RSpec.configure do |config|
  config.include BuildModelTable, type: :model
end
