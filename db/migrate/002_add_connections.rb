class AddConnections < ActiveRecord::Migration
  def change
    add_column :users, :number_of_connections, :integer
  end
end
