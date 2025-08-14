class EmailTemplate < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true

    validates :title, :html, presence: true
    validates :title, uniqueness: true

end
