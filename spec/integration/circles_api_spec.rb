require 'swagger_helper'

RSpec.describe 'Circles API', type: :request do
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
