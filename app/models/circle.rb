class Circle < ApplicationRecord
  belongs_to :frame, counter_cache: true

  validates :x, :y, :diameter, presence: true, numericality: true
  validate :must_be_within_frame
  validate :must_not_collide_with_other_circles

  def radius
    return 0 if diameter.nil?
    diameter / 2.0
  end

  def distance_to(other)
    return 0 if x.nil? || y.nil? || other.x.nil? || other.y.nil?
    Math.sqrt((x - other.x)**2 + (y - other.y)**2)
  end

  private

  def must_be_within_frame
    return if frame.nil? || x.nil? || y.nil? || diameter.nil?

    if (x - radius) < frame.min_x ||
       (x + radius) > frame.max_x ||
       (y - radius) < frame.min_y ||
       (y + radius) > frame.max_y
      errors.add(:base, "Circle must be completely inside the frame")
    end
  end

  def must_not_collide_with_other_circles
    return if frame.nil? || x.nil? || y.nil? || diameter.nil?

    frame.circles.where.not(id: id).each do |other|
      if distance_to(other) < (radius + other.radius)
        errors.add(:base, "Circle collides with another circle within the same frame")
      end
    end
  end
end
