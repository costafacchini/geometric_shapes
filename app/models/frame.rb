class Frame < ApplicationRecord
  has_many :circles, dependent: :destroy

  validates :x, :y, :width, :height, presence: true, numericality: true
  validate :cannot_touch_or_overlap_other_frames

  def min_x = x - width / 2.0
  def max_x = x + width / 2.0
  def min_y = y - height / 2.0
  def max_y = y + height / 2.0

  private

  def cannot_touch_or_overlap_other_frames
    Frame.where.not(id: id).each do |other|
      unless max_x <= other.min_x ||
             min_x >= other.max_x ||
             max_y <= other.min_y ||
             min_y >= other.max_y
        errors.add(:base, "Frame cannot touch or overlap another frame")
      end
    end
  end
end
