ActionMailer::Base.smtp_settings = {
  address: Figaro.env.smtp_address,
  port: Figaro.env.smtp_port.to_i,
  user_name: Figaro.env.smtp_user_name,
  password: Figaro.env.smtp_password,
  domain: Figaro.env.smtp_helo_domain_name,
  authentication: :plain,
  enable_starttls_auto: true
}
