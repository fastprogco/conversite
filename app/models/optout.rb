class Optout < ApplicationRecord
    validates :mobile_number, presence: true
end