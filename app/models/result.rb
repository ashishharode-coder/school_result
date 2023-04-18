class Result < ApplicationRecord

  def self.calculate_daily_stats
    today = Date.today
    subjects = Result.distinct.pluck(:subject)
    subjects.each do |subject|
      results = Result.where(subject: subject, timestamp: today.all_day)
      daily_stats = {
        date: today,
        subject: subject,
        daily_low: results.minimum(:marks),
        daily_high: results.maximum(:marks),
        result_count: results.count
      }
      DailyResultStat.create(daily_stats)
    end
  end

end
