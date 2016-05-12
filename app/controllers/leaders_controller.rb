class LeadersController < ApplicationController
  def create
    unless params[:token] == '4505d16a-230b-4832-b521-93499f696bb3'
      render text: params.inspect, status: :unauthorized
      return
    end
    leader_param = params.require(:leader)

    Leader.put(twitter_handle: leader_param[:twitter_handle], score: leader_param[:score])

    render nothing: true
  end

  def validate
    Leader.validate_all if params[:token] == '2e326efa-268a-4117-9e40-517679356a35'
    render nothing: true
  end

  def leaders_by_time
    unless params[:token] == '4505d16a-230b-4832-b521-93499f696bb3'
      render text: params.inspect, status: :unauthorized
      return
    end

    leaders = Leader.leaders_by_specific_time(
      params[:year],
      params[:month],
      params[:day],
      params[:hour],
      params[:minute],
      params[:second]
    )

    render json: leaders
  end

  def override_validation
    unless params[:token] == '4505d16a-230b-4832-b521-93499f696bb3'
      render text: params.inspect, status: :unauthorized
      return
    end

    Leader.where(twitter_handle: params[:twitter_handle]).each do |leader|
      leader.validated = true
      leader.save
    end

    render nothing: true
  end

  def index
    respond_to do |format|
      format.json do
        if params[:show_all]
          render json: Leader.all.map(&:attributes)
        else
          leaders = Leader.all_leaders.map do |leader|
            { twitter_handle: leader.twitter_handle, score: leader.score }
          end
          render json: leaders
        end
      end
    end
  end
end
