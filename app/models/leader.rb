class Leader < ActiveRecord::Base
  def self.validate_all
    Leader.where(validated: false).each do |leader|
      if Time.now - leader.created_at > 10.minutes
        leader.destroy!
      else
        leader.validated = LeaderboardValidator.new.should_be_on_leaderboard?(leader.twitter_handle)
        leader.save
      end
    end
  end
end
