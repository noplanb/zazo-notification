class Credentials < Settingslogic
  source "#{Rails.root}/config/credentials.yml"
  namespace Rails.env
end
