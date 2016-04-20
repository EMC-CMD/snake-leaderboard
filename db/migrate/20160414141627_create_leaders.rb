class CreateLeaders < ActiveRecord::Migration
  def change
    create_table :leaders do |t|
      t.string :twitter_handle
      t.integer :score
      t.boolean :validated, default: false

      t.timestamps null: false
    end
  end
end
