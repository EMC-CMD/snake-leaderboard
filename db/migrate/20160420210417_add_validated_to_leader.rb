class AddValidatedToLeader < ActiveRecord::Migration
  def change
    change_table :leaders do |t|
      t.column :validated, :string, default: false
    end
  end
end
