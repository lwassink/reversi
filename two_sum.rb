def two_sum(array, target)
  goal_els = {}

  array.each do |el|
    return true if goal_els[el]
    goal_els[target - el] = true
  end

  false
end
