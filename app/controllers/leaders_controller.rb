class LeadersController < ApplicationController
  def create
    unless params[:token] == '4505d16a-230b-4832-b521-93499f696bb3'
      render text: params.inspect, status: :unauthorized
      return
    end
    leader_param = params.require(:leader)

    Leader.where(twitter_handle: leader_param[:twitter_handle])
      .first_or_create
      .update_attributes(score: leader_param[:score])

    render nothing: true
  end

  def validate
    Leader.validate_all if params[:token] == '2e326efa-268a-4117-9e40-517679356a35'
    render nothing: true
  end

  def index
    respond_to do |format|
      format.json do
        if params[:show_all]
          render json: Leader.all.map(&:attributes)
        else
          leaders = Leader.where(validated: true).order('score DESC').limit(10).map do |leader|
            { twitter_handle: leader.twitter_handle, score: leader.score }
          end
          render json: leaders
        end
      end
    end
  end
end
