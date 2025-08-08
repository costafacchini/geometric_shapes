json.partial! "frame", frame: @frame

if @frame.circles.any?
  json.circle do
    json.partial! "frames/circles/circle", circle: @frame.circles.first
  end
end
