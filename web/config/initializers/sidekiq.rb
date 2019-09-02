
if Rails.env == 'production'
  sidekiq_config = {
    url: ENV['JOB_WORKER_URL'],
    password: Rails.application.credentials[Rails.env.to_sym][:redis_password]
  }

  Sidekiq.configure_server do |config|
    config.redis = sidekiq_config
  end

  Sidekiq.configure_client do |config|
    config.redis = sidekiq_config
  end
end
