class Leader < ActiveRecord::Base
  WINDOWS = [
    Time.zone.local(2016, 4, 26, 0, 0, 0)..Time.zone.local(2016, 5, 2, 17, 59, 59),
    Time.zone.local(2016, 5, 2, 18, 0, 0)..Time.zone.local(2016, 5, 2, 20, 59, 59),
    Time.zone.local(2016, 5, 2, 21, 0, 0)..Time.zone.local(2016, 5, 3, 16, 59, 59),
    Time.zone.local(2016, 5, 3, 17, 0, 0)..Time.zone.local(2016, 5, 4, 16, 59, 59)
  ]
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

  def self.current_leaders
    self.where(validated: true)
      .where(created_at: target_range)
      .order('score DESC')
      .limit(10)
  end

  def self.target_range
    WINDOWS.find {|w| w.begin <= Time.zone.now && Time.zone.now < w.end }
  end

  def self.put(attributes)
    where(twitter_handle: attributes[:twitter_handle], created_at: target_range)
    .first_or_create.tap do |leader|
      leader.update_attributes(attributes) unless leader.score.to_i > attributes[:score].to_i
    end
  end
end
