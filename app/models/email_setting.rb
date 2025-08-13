class EmailSetting < ApplicationRecord
  belongs_to :added_by, class_name: "User"
  belongs_to :edited_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :name, presence: true, uniqueness: { scope: :added_by_id, case_sensitive: false }
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :smtp_host, presence: true
  validates :port, presence: true, numericality: { only_integer: true }
  validates :user_name, presence: true
  validates :password, presence: true

  validates :added_by_id,
  uniqueness: {
    conditions: -> { where(is_deleted: false) },
    message: "can only have one active email setting"
  }

  default_scope { where(is_deleted: false) }

  def soft_delete(user = nil)
    update(is_deleted: true, deleted_by: user)
  end
end
