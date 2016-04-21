class ChangeValidatedToBoolean < ActiveRecord::Migration
  def change
    remove_column :leaders, :validated
    add_column :leaders, :validated, :boolean, default: false
  end
end
