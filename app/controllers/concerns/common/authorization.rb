module Common
  module Authorization
    extend ActiveSupport::Concern

    def authorize_super_admin
      unless is_super_admin?
        redirect_to root_path, alert: t("you_are_not_authorized_to_access_this_page")
      end
    end

  end
end
