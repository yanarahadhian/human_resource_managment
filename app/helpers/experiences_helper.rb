module ExperiencesHelper

  def data_type(p_type)
    case p_type
      when 'work'
        'Pekerjaan'
      when 'training'
        'Pelatihan'
      when 'organizational'
        'Organisasi'
    end
  end

 def popup_add_name(p_type, id = "")
    case p_type
      when 'work'
        "popup_work_#{id}"
      when 'training'
        'Pelatihan'
      when 'organizational'
        "popup_organization_#{id}"
    end
  end

  def tab(p_type)
    case p_type
      when 'work'
        '2'
      when 'organizational'
        '3'
    end
  end
end
