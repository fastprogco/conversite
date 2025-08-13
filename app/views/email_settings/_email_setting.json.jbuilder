json.extract! email_setting, :id, :name, :smtp_host, :port, :email_address, :user_name, :password, :created_at, :updated_at
json.url email_setting_url(email_setting, format: :json)
