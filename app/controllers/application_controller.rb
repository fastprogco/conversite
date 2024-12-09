class ApplicationController < ActionController::Base
  include SessionsHelper
  include Common::Locale
  include Common::Authorization
  include Common::GlobalConstants
end
