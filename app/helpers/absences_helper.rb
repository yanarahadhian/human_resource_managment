module AbsencesHelper 
  
  def total_week_overtime(person_id, date)
    presence_report = PresenceReport.find_by_person_id_and_date(person_id, date)
    total_overtime = 0
    unless presence_report.blank?
      total_overtime = presence_report.total_overtime_this_week
    end
    return total_overtime 
  end

  def is_error_name(str_error)
    data = false
    unless str_error.blank?
      if str_error.has_key?("person-name")
        data = true
      end
    end
    return data
  end

  def is_error_reason(str_error)
    data = false
    unless str_error.blank?
      if str_error.has_key?("alasan")
        data = true
      end
    end
    return data
  end

  def is_absent(absent_type)
    data = true
      unless absent_type.blank?
        if absent_type == 1
          data = false
        else
          data = true
        end
      end
    return data
  end
end