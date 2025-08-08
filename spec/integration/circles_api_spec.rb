require 'swagger_helper'

RSpec.describe 'Circles API', type: :request do
  path '/circles' do
    get('List circles with optional filters') do
      tags 'Circles'
      description 'Lists all circles, optionally filtered by frame and/or within a radius from a center point'
      produces 'application/json'

      parameter name: :frame_id, in: :query, type: :integer, required: false,
                description: 'Filter circles by frame ID'
      parameter name: :center_x, in: :query, type: :number, required: false,
                description: 'X coordinate of center point for radius search'
      parameter name: :center_y, in: :query, type: :number, required: false,
                description: 'Y coordinate of center point for radius search'
      parameter name: :radius, in: :query, type: :number, required: false,
                description: 'Search radius in centimeters (returns circles completely within this radius)'

      response(200, 'Circles retrieved successfully') do
        schema type: :object,
               properties: {
                 circles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       x: { type: :string, example: '10.0' },
                       y: { type: :string, example: '10.0' },
                       diameter: { type: :string, example: '2.0' },
                       radius: { type: :string, example: '1.0' },
                       frame_id: { type: :integer, example: 1 }
                     }
                   }
                 },
                 total_count: { type: :integer, example: 3 }
               },
               required: [ 'circles', 'total_count' ]

        context 'without filters' do
          let(:frame1) { create(:frame, x: 10, y: 10, width: 10, height: 10) }
          let(:frame2) { create(:frame, x: 25, y: 25, width: 10, height: 10) }

          before do
            create(:circle, frame: frame1, x: 8, y: 8, diameter: 2)
            create(:circle, frame: frame1, x: 12, y: 12, diameter: 2)
            create(:circle, frame: frame2, x: 25, y: 25, diameter: 3)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('circles', 'total_count')
            expect(data['circles']).to be_an(Array)
            expect(data['total_count']).to eq(3)
          end
        end

        context 'with frame filter' do
          let(:frame1) { create(:frame, x: 10, y: 10, width: 10, height: 10) }
          let(:frame2) { create(:frame, x: 25, y: 25, width: 10, height: 10) }
          let(:frame_id) { frame1.id }

          before do
            create(:circle, frame: frame1, x: 8, y: 8, diameter: 2)
            create(:circle, frame: frame1, x: 12, y: 12, diameter: 2)
            create(:circle, frame: frame2, x: 25, y: 25, diameter: 3)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['total_count']).to eq(2)
            expect(data['circles'].all? { |c| c['frame_id'] == frame1.id }).to be true
          end
        end

        context 'with radius search' do
          let(:frame) { create(:frame, x: 15, y: 15, width: 20, height: 20) }
          let(:center_x) { 10 }
          let(:center_y) { 10 }
          let(:radius) { 5 }

          before do
            # Circle completely within radius (distance + radius = 3 + 1 = 4 < 5)
            create(:circle, frame: frame, x: 8, y: 8, diameter: 2)
            # Circle partially within radius (distance + radius = 4.24 + 1 = 5.24 > 5)
            create(:circle, frame: frame, x: 13, y: 13, diameter: 2)
            # Circle far outside radius
            create(:circle, frame: frame, x: 20, y: 20, diameter: 2)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['total_count']).to eq(1)
          end
        end
      end
    end
  end

  path '/circles/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Circle ID'

    put('Update a circle') do
      tags 'Circles'
      description 'Updates the position or size of an existing circle'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :circle_params, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              x: {
                type: :number,
                description: 'X coordinate of circle center in centimeters',
                example: 11.0
              },
              y: {
                type: :number,
                description: 'Y coordinate of circle center in centimeters',
                example: 11.0
              },
              diameter: {
                type: :number,
                description: 'Diameter of circle in centimeters',
                example: 2.5
              }
            },
            required: [ 'x', 'y', 'diameter' ]
          }
        },
        required: [ 'circle' ]
      }

      response(200, 'Circle updated successfully') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 x: { type: :string, example: '11.0' },
                 y: { type: :string, example: '11.0' },
                 diameter: { type: :string, example: '2.5' },
                 radius: { type: :string, example: '1.25' },
                 frame_id: { type: :integer, example: 1 }
               },
               required: [ 'id', 'x', 'y', 'diameter', 'radius', 'frame_id' ]

        let(:frame) { create(:frame, x: 10, y: 10, width: 5, height: 5) }
        let(:circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }
        let(:id) { circle.id }
        let(:circle_params) { { circle: { x: 11.0, y: 11.0, diameter: 2.5 } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('id', 'x', 'y', 'diameter', 'radius', 'frame_id')
        end
      end

      response(422, 'Invalid circle parameters') do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Circle must be completely inside the frame" ]
                 }
               }

        context 'circle moved outside frame boundaries' do
          let(:frame) { create(:frame, x: 10, y: 10, width: 5, height: 5) }
          let(:circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }
          let(:id) { circle.id }
          let(:circle_params) { { circle: { x: 15.0, y: 15.0, diameter: 2.0 } } }
          run_test!
        end



        context 'invalid parameters' do
          let(:frame) { create(:frame, x: 10, y: 10, width: 5, height: 5) }
          let(:circle) { create(:circle, frame: frame, x: 10, y: 10, diameter: 2) }
          let(:id) { circle.id }
          let(:circle_params) { { circle: { x: nil, y: 11.0, diameter: 2.0 } } }
          run_test!
        end
      end

      response(404, 'Circle not found') do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Circle not found' }
               }

        let(:id) { 999 }
        let(:circle_params) { { circle: { x: 11.0, y: 11.0, diameter: 2.0 } } }
        run_test!
      end
    end
  end
end
