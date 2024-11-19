# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :name, presence: true
  validates :role, presence: true

  validate :password_match_confirmation, on: :create
  validates :password_confirmation, presence: true, on: :create
  before_create :generate_confirmation_instructions
  before_validation :strip_user_name



  
  def generate_confirmation_instructions
    self.email_confirmation_token = SecureRandom.urlsafe_base64.to_s
    self.email_confirmation_sent_at = Time.now.utc
  end

  def confirm_email!
    self.email_confirmation_token = nil
    self.email_confirmed_at = Time.now.utc
    save
  end

  def generate_phone_confirmation_instructions
    self.phone_confirmation_token = Array.new(4) { rand(0..9) }.join
    self.phone_confirmation_sent_at = Time.now.utc
    save
  end

  def confirm_phone!
    self.phone_confirmation_token = nil
    self.phone_confirmed_at = Time.now.utc
    save
  end

  def generate_password_reset
    self.reset_password_token = SecureRandom.urlsafe_base64.to_s
    self.reset_password_sent_at = Time.now.utc
    save
  end

  def password_token_valid?
    (self.reset_password_sent_at + 2.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save
  end

  private

  def password_match_confirmation
    errors.add(:password_confirmation, I18n.t("must_match_password")) unless password == password_confirmation
  end

  def strip_user_name
    self.name = name.strip if name.present?
  end
end