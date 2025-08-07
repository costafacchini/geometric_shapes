FactoryBot.define do
  factory :circle do
    x { 10 }
    y { 10 }
    diameter { 2 }
    association :frame
  end
end
