class BroadcastReport < ApplicationRecord
  belongs_to :broadcast

  enum message_status: {
    sent: 0,
    delivered: 1,
    read: 2,
    replied: 3,
    failed: 4
  }
end
