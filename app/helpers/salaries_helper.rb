module SalariesHelper
  def current_total_month(per_year, per_month)
  	month = per_year/per_month
  	return number_with_precision(month.round.to_i, :precision => 0)
  end
end