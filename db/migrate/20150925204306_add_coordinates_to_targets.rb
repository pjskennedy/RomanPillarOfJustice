class AddCoordinatesToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :lat_tt, :float
    add_column :targets, :loft_tt, :float
  end
end
