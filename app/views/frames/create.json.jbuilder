json.partial! "frame", frame: @frame

if @circle.present?
  json.circle do
    json.partial! "frames/circles/circle", circle: @circle
  end
end
