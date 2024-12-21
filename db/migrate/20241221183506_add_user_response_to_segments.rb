class AddUserResponseToSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :segments, :user_response, :text
  end
end
