class Template < ApplicationRecord
  belongs_to :added_by, class_name: "User"
  belongs_to :edited_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :meta_template_name, presence: true
  validates :language, presence: true
end
