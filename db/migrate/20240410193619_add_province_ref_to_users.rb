class AddProvinceRefToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :province, null: false, foreign_key: true, default: 1
  end
end
