module SettingsHelper

  def is_company_overtime(hr)
    data = false
    unless hr.blank?
      unless hr.is_company_overtime.blank?
        data = hr.is_company_overtime
      end
    end
    return data
  end

  def str_is_company_overtime(hr)
    str = "Sesuai dengan peraturan Kementrian Tenaga Kerja"
    if is_company_overtime(hr)
      str = "Sesuai dengan upah pro rata per jam"
    end
    return str
  end


end