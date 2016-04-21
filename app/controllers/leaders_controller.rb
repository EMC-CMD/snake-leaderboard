class LeadersController < ApplicationController
  def create
    unless params[:token] == '4505d16a-230b-4832-b521-93499f696bb3'
      render text: params.inspect, status: :unauthorized
      return
    end
    leader_param = params.require(:leader)

    Leader.create(leader_param.permit(:twitter_handle, :score))

    render nothing: true
  end

  def index
    respond_to do |format|
      format.json do
        leaders = Leader.where(validated: true).order('score DESC').limit(10).map do |leader|
          { twitter_handle: leader.twitter_handle, score: leader.score }
        end
        render json: leaders
      end
    end
  end
end
