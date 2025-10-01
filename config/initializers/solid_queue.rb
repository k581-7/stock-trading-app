Rails.application.config.after_initialize do
  if defined?(SolidQueue)
    SolidQueue.logger = Rails.logger
  end
end
