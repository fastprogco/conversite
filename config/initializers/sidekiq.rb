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
    config.redis = { url: ENV['REDIS_TLS_URL']  }
    end

    Sidekiq.configure_client do |config|
    config.redis = { url:  ENV['REDIS_TLS_URL'] }
    end
end