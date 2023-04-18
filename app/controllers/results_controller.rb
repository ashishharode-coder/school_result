class ResultsController < ApplicationController
  def create
    result_data = request.parameters.except(:controller, :action)
    result = Result.create(subject: result_data["subject"], timestamp: result_data["timestamp"], marks: result_data["marks"])
    render json: {message: "saved successfully", data: result}, status: :ok
  end
end
