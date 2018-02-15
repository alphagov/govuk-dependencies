def old_pull_request?(date)
  today = Date.today
  actual_age = (today - date).to_i
  weekdays_age = if today.monday?
                   actual_age - 2
                 elsif today.tuesday?
                   actual_age - 1
                 else
                   actual_age
                 end
  weekdays_age > 2
end
