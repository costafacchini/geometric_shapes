require 'rails_helper'

RSpec.describe Frame, type: :model do
  subject { build(:frame) }

  describe 'circles' do
    it { should have_many(:circles).dependent(:destroy) }
  end

  describe 'x' do
    it { should validate_presence_of(:x) }
    it { should validate_numericality_of(:x) }
  end

  describe 'y' do
    it { should validate_presence_of(:y) }
    it { should validate_numericality_of(:y) }
  end

  describe 'width' do
    it { should validate_presence_of(:width) }
    it { should validate_numericality_of(:width) }
  end

  describe 'height' do
    it { should validate_presence_of(:height) }
    it { should validate_numericality_of(:height) }
  end

  describe 'coordinate calculation methods' do
    let(:frame) { build(:frame, x: 10, y: 20, width: 6, height: 8) }

    describe '#min_x' do
      it 'returns the leftmost x coordinate' do
        expect(frame.min_x).to eq(7.0)
      end
    end

    describe '#max_x' do
      it 'returns the rightmost x coordinate' do
        expect(frame.max_x).to eq(13.0)
      end
    end

    describe '#min_y' do
      it 'returns the bottommost y coordinate' do
        expect(frame.min_y).to eq(16.0)
      end
    end

    describe '#max_y' do
      it 'returns the topmost y coordinate' do
        expect(frame.max_y).to eq(24.0)
      end
    end
  end

  describe 'overlap validation' do
    let!(:existing_frame) { create(:frame, x: 10, y: 10, width: 4, height: 4) }

    context 'when frames do not overlap' do
      it 'is valid when frame is completely to the left' do
        frame = build(:frame, x: 5, y: 10, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frame is completely to the right' do
        frame = build(:frame, x: 15, y: 10, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frame is completely above' do
        frame = build(:frame, x: 10, y: 15, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frame is completely below' do
        frame = build(:frame, x: 10, y: 5, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frame is in diagonal position' do
        frame = build(:frame, x: 15, y: 15, width: 2, height: 2)
        expect(frame).to be_valid
      end
    end

    context 'when frames overlap' do
      it 'is invalid when frames overlap horizontally' do
        frame = build(:frame, x: 11, y: 10, width: 4, height: 2)
        expect(frame).not_to be_valid
        expect(frame.errors[:base]).to include('Frame cannot touch or overlap another frame')
      end

      it 'is invalid when frames overlap vertically' do
        frame = build(:frame, x: 10, y: 11, width: 2, height: 4)
        expect(frame).not_to be_valid
        expect(frame.errors[:base]).to include('Frame cannot touch or overlap another frame')
      end

      it 'is invalid when one frame is completely inside another' do
        frame = build(:frame, x: 10, y: 10, width: 2, height: 2)
        expect(frame).not_to be_valid
        expect(frame.errors[:base]).to include('Frame cannot touch or overlap another frame')
      end

      it 'is invalid when frames overlap diagonally' do
        frame = build(:frame, x: 12, y: 12, width: 4, height: 4)
        expect(frame).not_to be_valid
        expect(frame.errors[:base]).to include('Frame cannot touch or overlap another frame')
      end
    end

    context 'when frames touch but do not overlap' do
      it 'is valid when frames touch on the right edge' do
        frame = build(:frame, x: 13, y: 10, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frames touch on the left edge' do
        frame = build(:frame, x: 7, y: 10, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frames touch on the top edge' do
        frame = build(:frame, x: 10, y: 13, width: 2, height: 2)
        expect(frame).to be_valid
      end

      it 'is valid when frames touch on the bottom edge' do
        frame = build(:frame, x: 10, y: 7, width: 2, height: 2)
        expect(frame).to be_valid
      end
    end

    context 'when updating an existing frame' do
      let!(:frame_to_update) { create(:frame, x: 20, y: 20, width: 2, height: 2) }

      it 'does not validate against itself' do
        frame_to_update.x = 21
        expect(frame_to_update).to be_valid
      end

      it 'validates against other frames when moved to overlap' do
        frame_to_update.x = 11
        frame_to_update.y = 11
        expect(frame_to_update).not_to be_valid
        expect(frame_to_update.errors[:base]).to include('Frame cannot touch or overlap another frame')
      end
    end
  end

  describe 'edge cases' do
    it 'handles frames with decimal coordinates' do
      frame = build(:frame, x: 10.5, y: 20.3, width: 3.7, height: 4.2)
      expect(frame.min_x).to eq(8.65)
      expect(frame.max_x).to eq(12.35)
      expect(frame.min_y).to eq(18.2)
      expect(frame.max_y).to eq(22.4)
    end

    it 'handles frames with zero dimensions' do
      frame = build(:frame, x: 10, y: 10, width: 0, height: 0)
      expect(frame.min_x).to eq(10.0)
      expect(frame.max_x).to eq(10.0)
      expect(frame.min_y).to eq(10.0)
      expect(frame.max_y).to eq(10.0)
    end

    it 'handles negative coordinates' do
      frame = build(:frame, x: -5, y: -10, width: 4, height: 6)
      expect(frame.min_x).to eq(-7.0)
      expect(frame.max_x).to eq(-3.0)
      expect(frame.min_y).to eq(-13.0)
      expect(frame.max_y).to eq(-7.0)
    end
  end
end
