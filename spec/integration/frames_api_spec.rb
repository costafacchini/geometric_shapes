require 'swagger_helper'

RSpec.describe 'Frames API', type: :request do
  path '/frames' do
    post('Create a frame') do
      tags 'Frames'
      description 'Creates a new frame with specified dimensions and position'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :frame_params, in: :body, schema: {
        type: :object,
        properties: {
          frame: {
            type: :object,
            properties: {
              x: {
                type: :number,
                description: 'X coordinate of frame center in centimeters',
                example: 10.0
              },
              y: {
                type: :number,
                description: 'Y coordinate of frame center in centimeters',
                example: 10.0
              },
              width: {
                type: :number,
                description: 'Width of frame in centimeters',
                example: 5.0
              },
              height: {
                type: :number,
                description: 'Height of frame in centimeters',
                example: 5.0
              }
            },
            required: [ 'x', 'y', 'width', 'height' ]
          }
        },
        required: [ 'frame' ]
      }

      response(201, 'Frame created successfully') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 x: { type: :string, example: '10.0' },
                 y: { type: :string, example: '10.0' },
                 width: { type: :string, example: '5.0' },
                 height: { type: :string, example: '5.0' },
                 circles_count: { type: :integer, example: 0 }
               },
               required: [ 'id', 'x', 'y', 'width', 'height', 'circles_count' ]

        let(:frame_params) { { frame: { x: 10.0, y: 10.0, width: 5.0, height: 5.0 } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('id', 'x', 'y', 'width', 'height', 'circles_count')
        end
      end

      response(422, 'Invalid parameters') do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "X can't be blank" ]
                 }
               }

        context 'missing required parameter' do
          let(:frame_params) { { frame: { x: nil, y: 10.0, width: 5.0, height: 5.0 } } }
          run_test!
        end

        context 'invalid numeric values' do
          let(:frame_params) { { frame: { x: 'invalid', y: 10.0, width: 5.0, height: 5.0 } } }
          run_test!
        end

        context 'negative dimensions' do
          let(:frame_params) { { frame: { x: 10.0, y: 10.0, width: -5.0, height: 5.0 } } }
          run_test!
        end

        context 'overlapping frame' do
          let(:frame_params) { { frame: { x: 10.0, y: 10.0, width: 5.0, height: 5.0 } } }

          before do
            create(:frame, x: 10, y: 10, width: 5, height: 5) # Frame que vai causar overlap
          end

          run_test!
        end
      end
    end
  end

  path '/frames/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Frame ID'

    get('Get frame details') do
      tags 'Frames'
      description 'Retrieves frame details including circle position metrics'
      produces 'application/json'

      response(200, 'Frame found') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 x: { type: :string, example: '10.0' },
                 y: { type: :string, example: '10.0' },
                 width: { type: :string, example: '5.0' },
                 height: { type: :string, example: '5.0' },
                 circles_count: { type: :integer, example: 2 },
                 highest_circle: {
                   type: :object,
                   properties: {
                     x: { type: :string, example: '11.5' },
                     y: { type: :string, example: '11.5' }
                   },
                   nullable: true
                 },
                 lowest_circle: {
                   type: :object,
                   properties: {
                     x: { type: :string, example: '10.0' },
                     y: { type: :string, example: '10.0' }
                   },
                   nullable: true
                 },
                 leftmost_circle: {
                   type: :object,
                   properties: {
                     x: { type: :string, example: '10.0' },
                     y: { type: :string, example: '10.0' }
                   },
                   nullable: true
                 },
                 rightmost_circle: {
                   type: :object,
                   properties: {
                     x: { type: :string, example: '11.5' },
                     y: { type: :string, example: '11.5' }
                   },
                   nullable: true
                 }
               }

        context 'frame without circles' do
          let(:id) { create(:frame, x: 10, y: 10, width: 5, height: 5).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('id', 'x', 'y', 'width', 'height', 'circles_count')
            expect(data['circles_count']).to eq(0)
            expect(data['highest_circle']).to be_nil
            expect(data['lowest_circle']).to be_nil
            expect(data['leftmost_circle']).to be_nil
            expect(data['rightmost_circle']).to be_nil
          end
        end

        context 'frame with multiple circles' do
          let(:frame) { create(:frame, x: 10, y: 10, width: 5, height: 5) }
          let(:id) { frame.id }

          before do
            create(:circle, frame: frame, x: 10, y: 10, diameter: 2)
            create(:circle, frame: frame, x: 11.5, y: 11.5, diameter: 2)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('id', 'x', 'y', 'width', 'height', 'circles_count')
            expect(data['circles_count']).to eq(2)
            expect(data['highest_circle']).not_to be_nil
            expect(data['lowest_circle']).not_to be_nil
            expect(data['leftmost_circle']).not_to be_nil
            expect(data['rightmost_circle']).not_to be_nil
          end
        end
      end

      response(404, 'Frame not found') do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Frame not found' }
               }

        let(:id) { 999 }
        run_test!
      end
    end

    delete('Delete a frame') do
      tags 'Frames'
      description 'Deletes a frame if it has no associated circles'
      produces 'application/json'

      response(204, 'Frame deleted successfully') do
        let(:id) { create(:frame, x: 10, y: 10, width: 5, height: 5).id }
        run_test!
      end

      response(422, 'Frame has associated circles') do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Cannot delete frame with associated circles' }
               }

        let(:frame) { create(:frame, x: 10, y: 10, width: 5, height: 5) }
        let(:id) { frame.id }

        before do
          create(:circle, frame: frame, x: 10, y: 10, diameter: 2)
        end

        run_test!
      end

      response(404, 'Frame not found') do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Frame not found' }
               }

        let(:id) { 999 }
        run_test!
      end
    end
  end
end
