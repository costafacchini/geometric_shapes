class AddCirclesCountToFrames < ActiveRecord::Migration[8.0]
  def change
    add_column :frames, :circles_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Frame.find_each do |frame|
          Frame.reset_counters(frame.id, :circles)
        end
      end
    end
  end
end
