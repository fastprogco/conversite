class CreateEmailTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :email_templates do |t|
      t.string :title
      t.text :html

      t.timestamps
    end
  end
end
