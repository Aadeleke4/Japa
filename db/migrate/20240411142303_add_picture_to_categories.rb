class AddPictureToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :picture, :json
  end
end
