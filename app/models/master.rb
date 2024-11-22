class Master < ApplicationRecord

  # validates :file_name, presence: true
  # validates :date, presence: true
  # validates :mobile, presence: true
  # validates :nationality, presence: true
  # validates :procedure, presence: true
  # validates :procedure_name, presence: true
  # validates :amount, presence: true, numericality: true
  # validates :area_name, presence: true
  # validates :master_project, presence: true
  # validates :project, presence: true
  # validates :property_type, presence: true
  # validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  # validates :phone, presence: true
  # validates :id_number, presence: true
  # validates :uae_id, presence: true
  # validates :unified_num, presence: true

  # before_validation :strip_fields

  # private

  # def strip_fields
  #   self.file_name = file_name.strip if file_name.present?
  #   self.nationality = nationality.strip if nationality.present?
  #   self.procedure = procedure.strip if procedure.present?
  #   self.procedure_name = procedure_name.strip if procedure_name.present?
  #   self.area_name = area_name.strip if area_name.present?
  #   self.master_project = master_project.strip if master_project.present?
  #   self.project = project.strip if project.present?
  #   self.property_type = property_type.strip if property_type.present?
  #   self.email = email.strip if email.present?
  #   self.phone = phone.strip if phone.present?
  #   self.id_number = id_number.strip if id_number.present?
  #   self.uae_id = uae_id.strip if uae_id.present?
  #   self.unified_num = unified_num.strip if unified_num.present?
  # end
end