require 'rails_helper'

RSpec.describe Circle, type: :model do
  subject { build(:circle) }

  describe 'frame' do
    it { should belong_to(:frame) }
  end

  describe 'x' do
    it { should validate_presence_of(:x) }
    it { should validate_numericality_of(:x) }
  end

  describe 'y' do
    it { should validate_presence_of(:y) }
    it { should validate_numericality_of(:y) }
  end

  describe 'diameter' do
    it { should validate_presence_of(:diameter) }
    it { should validate_numericality_of(:diameter) }
  end

  describe '#radius' do
    it 'returns half of the diameter' do
      circle = build(:circle, diameter: 6)
      expect(circle.radius).to eq(3.0)
    end

    it 'handles decimal diameters' do
      circle = build(:circle, diameter: 5.5)
      expect(circle.radius).to eq(2.75)
    end

    it 'returns 0 when diameter is nil' do
      circle = build(:circle, diameter: nil)
      expect(circle.radius).to eq(0)
    end
  end

  describe '#distance_to' do
    let(:circle1) { build(:circle, x: 0, y: 0) }
    let(:circle2) { build(:circle, x: 3, y: 4) }

    it 'calculates distance between two circles' do
      expect(circle1.distance_to(circle2)).to eq(5.0)
    end

    it 'calculates distance when circles are at same position' do
      circle2.x = 0
      circle2.y = 0
      expect(circle1.distance_to(circle2)).to eq(0.0)
    end

    it 'calculates distance with decimal coordinates' do
      circle2.x = 1.5
      circle2.y = 2.0
      expect(circle1.distance_to(circle2)).to be_within(0.01).of(2.5)
    end

    it 'returns 0 when coordinates are nil' do
      circle1.x = nil
      expect(circle1.distance_to(circle2)).to eq(0)
    end
  end

  describe 'frame boundary validation' do
    let(:frame) { create(:frame, x: 10, y: 10, width: 10, height: 10) }

    context 'when circle is completely inside frame' do
      it 'is valid when circle is at center' do
        circle = build(:circle, frame: frame, x: 10, y: 10, diameter: 2)
        expect(circle).to be_valid
      end

      it 'is valid when circle touches frame edges' do
        circle = build(:circle, frame: frame, x: 6, y: 10, diameter: 2)
        expect(circle).to be_valid
      end

      it 'is valid when circle is near frame edges' do
        circle = build(:circle, frame: frame, x: 8, y: 8, diameter: 2)
        expect(circle).to be_valid
      end
    end

    context 'when circle extends beyond frame boundaries' do
      it 'is invalid when circle extends beyond left edge' do
        circle = build(:circle, frame: frame, x: 4, y: 10, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle must be completely inside the frame')
      end

      it 'is invalid when circle extends beyond right edge' do
        circle = build(:circle, frame: frame, x: 16, y: 10, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle must be completely inside the frame')
      end

      it 'is invalid when circle extends beyond top edge' do
        circle = build(:circle, frame: frame, x: 10, y: 16, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle must be completely inside the frame')
      end

      it 'is invalid when circle extends beyond bottom edge' do
        circle = build(:circle, frame: frame, x: 10, y: 4, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle must be completely inside the frame')
      end

      it 'is invalid when circle extends beyond multiple edges' do
        circle = build(:circle, frame: frame, x: 4, y: 4, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle must be completely inside the frame')
      end
    end
  end

  describe 'collision validation' do
    let(:frame) { create(:frame, x: 10, y: 10, width: 20, height: 20) }

    context 'when circles do not collide' do
      let!(:existing_circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }

      it 'is valid when circles are far apart' do
        circle = build(:circle, frame: frame, x: 18, y: 18, diameter: 2)
        expect(circle).to be_valid
      end

      it 'is valid when circles touch but do not overlap' do
        circle = build(:circle, frame: frame, x: 13, y: 10, diameter: 2)
        expect(circle).to be_valid
      end

      it 'is valid when circles are at opposite corners' do
        circle = build(:circle, frame: frame, x: 5, y: 5, diameter: 2)
        expect(circle).to be_valid
      end
    end

    context 'when circles collide' do
      let!(:existing_circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }

      it 'is invalid when circles overlap' do
        circle = build(:circle, frame: frame, x: 11, y: 10, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle collides with another circle within the same frame')
      end

      it 'is invalid when one circle is completely inside another' do
        circle = build(:circle, frame: frame, x: 10, y: 10, diameter: 4)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle collides with another circle within the same frame')
      end

      it 'is invalid when circles touch edges' do
        circle = build(:circle, frame: frame, x: 11.5, y: 10, diameter: 2)
        expect(circle).not_to be_valid
        expect(circle.errors[:base]).to include('Circle collides with another circle within the same frame')
      end
    end

    context 'when updating an existing circle' do
      let!(:circle_to_update) { create(:circle, frame: frame, x: 18, y: 18, diameter: 2) }
      let!(:other_circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }

      it 'does not validate against itself' do
        circle_to_update.x = 19
        expect(circle_to_update).to be_valid
      end

      it 'validates against other circles when moved to collide' do
        circle_to_update.x = 11
        circle_to_update.y = 10
        expect(circle_to_update).not_to be_valid
        expect(circle_to_update.errors[:base]).to include('Circle collides with another circle within the same frame')
      end
    end
  end

  describe 'edge cases' do
    let(:frame) { create(:frame, x: 10, y: 10, width: 20, height: 20) }

    it 'handles circles with decimal coordinates' do
      circle = build(:circle, frame: frame, x: 10.5, y: 10.3, diameter: 2.5)
      expect(circle).to be_valid
    end

    it 'handles very small circles' do
      circle = build(:circle, frame: frame, x: 10, y: 10, diameter: 0.1)
      expect(circle).to be_valid
    end

    it 'handles circles at frame boundaries' do
      circle = build(:circle, frame: frame, x: 5, y: 10, diameter: 2)
      expect(circle).to be_valid
    end

    it 'handles multiple circles in the same frame' do
      create(:circle, frame: frame, x: 10, y: 10, diameter: 2)
      create(:circle, frame: frame, x: 18, y: 18, diameter: 2)
      circle = build(:circle, frame: frame, x: 5, y: 5, diameter: 2)
      expect(circle).to be_valid
    end
  end

  describe 'complex scenarios' do
    let(:frame) { create(:frame, x: 10, y: 10, width: 20, height: 20) }

    it 'handles multiple circles with different sizes' do
      create(:circle, frame: frame, x: 10, y: 10, diameter: 4)
      create(:circle, frame: frame, x: 18, y: 18, diameter: 2)
      circle = build(:circle, frame: frame, x: 5, y: 5, diameter: 3)
      expect(circle).to be_valid
    end

    it 'validates collision with circles of different sizes' do
      create(:circle, frame: frame, x: 10, y: 10, diameter: 6)
      circle = build(:circle, frame: frame, x: 12, y: 10, diameter: 2)
      expect(circle).not_to be_valid
      expect(circle.errors[:base]).to include('Circle collides with another circle within the same frame')
    end
  end
end
