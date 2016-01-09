class CreateReactions < ActiveRecord::Migration
  def change
    create_table :reactions do |t|
      t.attachment :animation
      t.boolean :is_sent, default: false
    end
  end
end
