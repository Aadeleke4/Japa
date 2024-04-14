class CreateContactPages < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_pages do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
