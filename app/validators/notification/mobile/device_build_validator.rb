class Notification::Mobile::DeviceBuildValidator < ActiveModel::Validator
  def validate(record)
    if record.device_platform == 'ios' && !Notification::Mobile::ALLOWED_DEVICE_BUILDS.include?(record.device_build)
      record.errors.add(:device_build, 'is not valid device build')
    end
  end
end
