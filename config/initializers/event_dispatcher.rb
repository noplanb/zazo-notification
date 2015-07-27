EventDispatcher.disable_send_message! if Rails.env.in? %w(development test playground)
