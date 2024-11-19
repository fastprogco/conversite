# app/controllers/concerns/common/locale.rb  
module Common
  module Locale
    extend ActiveSupport::Concern

    included do
      before_action :set_locale
    end

    def set_locale
      if params[:locale]
        I18n.locale = params[:locale]
        session[:locale] = I18n.locale
      else
        I18n.locale = session[:locale] || I18n.default_locale
      end
    end

    def default_url_options(options = {})
      { locale: I18n.locale }.merge!(options)
    end
  end
end
