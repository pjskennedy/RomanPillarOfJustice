class AddIsValidToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :is_valid, :boolean, default: false, null: false
  end
end
