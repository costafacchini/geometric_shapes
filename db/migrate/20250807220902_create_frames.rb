class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.decimal :x
      t.decimal :y
      t.decimal :width
      t.decimal :height

      t.timestamps
    end
  end
end
