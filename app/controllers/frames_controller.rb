class FramesController < ApplicationController
  before_action :set_frame, only: [ :show, :destroy ]

  # POST /frames
  def create
    @frame = Frame.new(frame_params.except(:circle))
    @circle = nil

    Frame.transaction do
      if @frame.save
        if circle_params.present?
          @circle = @frame.circles.build(circle_params)
          unless @circle.save
            raise ActiveRecord::Rollback
          end
        end
        render :create, status: :created
      else
        render json: { errors: @frame.errors.full_messages }, status: :unprocessable_content
      end
    rescue ActiveRecord::Rollback
      errors = @frame.errors.full_messages + (@circle&.errors&.full_messages || [])
      render json: { errors: errors }, status: :unprocessable_content
    end
  end

  # GET /frames/:id
  def show
    render :show
  end

  # DELETE /frames/:id
  def destroy
    if @frame.circles.exists?
      render json: { error: "Cannot delete frame with associated circles" }, status: :unprocessable_content
    else
      @frame.destroy
      head :no_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  end

  def frame_params
    params.require(:frame).permit(:x, :y, :width, :height, circle: [ :x, :y, :diameter ])
  end

  def circle_params
    frame_params[:circle]
  end
end
