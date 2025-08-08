json.partial! "frame", frame: @frame

if @frame.circles.any?
  json.highest_circle do
    circle = @frame.circles.order(y: :desc).first
    json.x circle.x
    json.y circle.y
  end

  json.lowest_circle do
    circle = @frame.circles.order(y: :asc).first
    json.x circle.x
    json.y circle.y
  end

  json.leftmost_circle do
    circle = @frame.circles.order(x: :asc).first
    json.x circle.x
    json.y circle.y
  end

  json.rightmost_circle do
    circle = @frame.circles.order(x: :desc).first
    json.x circle.x
    json.y circle.y
  end
else
  json.highest_circle nil
  json.lowest_circle nil
  json.leftmost_circle nil
  json.rightmost_circle nil
end
