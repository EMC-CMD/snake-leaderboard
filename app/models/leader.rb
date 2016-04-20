class Leader < ActiveRecord::Base
  def self.validate_and_get_top_ten
    results = []
    Leader.order('score DESC').each do |leader|
      break if results.size == 10
      unless leader.validated?
        leader.validated = LeaderboardValidator.new.should_be_on_leaderboard?(leader.twitter_handle)
        leader.save
      end
      results << leader if leader.validated?
    end
    results
  end
end
