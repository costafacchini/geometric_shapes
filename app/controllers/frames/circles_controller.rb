class Frames::CirclesController < ApplicationController
  before_action :set_frame

  # POST /frames/:frame_id/circles
  def create
    @circle = @frame.circles.build(circle_params)

    if @circle.save
      render :create, status: :created
    else
      render json: { errors: @circle.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:frame_id])
  end

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
