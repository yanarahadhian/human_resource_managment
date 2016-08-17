module PayrollsHelper
  
  def is_jamsostek_value(payrol)
    data = false
    unless payrol.jamsostek_value.blank?
      if payrol.jamsostek_value > 0
        data = true
      end
    end
    return data
  end

end
