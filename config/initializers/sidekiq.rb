if Rails.env.development?
    Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/0' }
    end

    Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/0' }
    end
end

if Rails.env.production?
    Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
    end

    Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
    end
end