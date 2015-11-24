class Notification::Mobile::PayloadStructureValidator < ActiveModel::Validator
  def validate(record)
    if record.payload.kind_of? Hash
      record.errors.add(:payload, 'type attribute should be persisted') unless record.payload[:type]
    else
      record.errors.add(:payload, 'should be type of hash')
    end
  end
end
