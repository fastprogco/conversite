class EmailTemplate < ApplicationRecord
  belongs_to :added_by, class_name: "User"
  belongs_to :edited_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :title, presence: true, uniqueness: true
  validates :html, presence: true, if: -> { !html_file.attached? }

  has_one_attached :html_file
end
