class NumberOfRequestsAccepted < ActiveRecord::Migration
  def change
    add_column :users, :number_of_requests_accepted, :integer
  end
end
