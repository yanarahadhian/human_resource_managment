class String
  def display
    self.blank? ? 'N/A' : self.humanize
  end
  def just_display
    self.blank? ? 'N/A' : self
  end
  def header_display
    self.blank? ? 'Karyawan' : self.humanize
  end
end

class NilClass
  def display
    'N/A'
  end
  def just_display
    'N/A'
  end
  def header_display
    'Karyawan'
  end
end

