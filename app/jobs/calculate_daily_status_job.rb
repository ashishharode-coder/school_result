class CalculateDailyStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @today = Date.today
    puts "start at #{Time.now}"
    calculate_daily_stats
    calculate_monthly_averages if monday_of_third_wednesday?
    puts "Ends at #{Time.now}"
  end

  private


  def calculate_daily_stats
    results = Result.where('timestamp >= ?', @today.beginning_of_day)
    if results.present?
      daily_stats = {
        date: @today,
        subject: results.first.subject,
        daily_low: results.minimum(:marks),
        daily_high: results.maximum(:marks),
        result_count: results.count
      }
      DailyResultStat.create(daily_stats)
    end
  end

  def calculate_monthly_averages
    # get the daily_result_stats data for at least 5 days before today
    days_to_go_back = 5
    daily_stats = []
    while daily_stats.pluck(:result_count).sum.eql?(0)  || (daily_stats.pluck(:result_count).sum != daily_stats.pluck(:result_count).sum) 

      start_date = @today - days_to_go_back
      daily_stats = DailyResultStat.where(date: start_date..@today, subject: 'Science').order(date: :desc)
      days_to_go_back += 1
    end

    # calculate the monthly averages
    result_count_used = daily_stats.sum { |day| day[:result_count] }
    monthly_avg_low = daily_stats.sum { |day| day[:daily_low] } / daily_stats.size
    monthly_avg_high = daily_stats.sum { |day| day[:daily_high] } / daily_stats.size

    # create a new MonthlyAverage object to store the results
    MonthlyAverage.create(
      date: @today,
      subject: 'Science',
      monthly_avg_low: monthly_avg_low.round(2),
      monthly_avg_high: monthly_avg_high.round(2),
      monthly_result_count_used: result_count_used
    )
  end

  def monday_of_third_wednesday?
    today = @today
    third_wednesday = (today.beginning_of_month..today.end_of_month).detect { |d| d.wday == 3 && d.day >= 15 }
    return today == third_wednesday-2
  end

end
