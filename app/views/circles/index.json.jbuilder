json.circles @circles do |circle|
  json.partial! "circle", circle: circle
end

json.total_count @circles.size
