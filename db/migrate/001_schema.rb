class Schema < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.text :request_message
      t.string :profile_link
      t.string :avatar_url
      t.string :headline
      t.string :name
      t.string :user_id
    end
  end
end
