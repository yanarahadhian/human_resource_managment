module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /home\s?page/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    
    else
      if page_name.include? "person"
        get_person(page_name)        
      elsif page_name.include? "employment"
        cond = page_name.gsub("employment dengan ", "")
        a = "person".classify.constantize.first(:conditions => cond)
        "/people/#{a.id}/employments?tab=0"
      elsif page_name.include? "pelanggaran"
        get_memorandums_violations(page_name)
      elsif page_name.include? "SP"
        get_memorandums_violations(page_name)
      elsif page_name.include? "gaji"
        get_gaji(page_name)
      elsif page_name.include? "kecelakaan"
        get_accidents(page_name)
      elsif page_name.include? "riwayat"
        get_histories(page_name)
      else
        begin          
          page_name =~ /halaman (.*)/
          #page_name =~ /^(.*) halaman( dengan (.*))?$/
          path_components = $1.split(/\s+/)
          a = path_components.push('path').join('_').to_sym
          self.send(a)
        rescue Object => e
            raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
              "Now, go and add a mapping in #{__FILE__}"
        end
      end
#      begin
#        page_name =~ /^(.*) page( with (.*))?$/
#        conditions = $3
#        path_components = $1.split(/\s+/)
#        if conditions.nil?
#          puts "==========++#{path_components.push('path').join('_').to_sym}"
#          self.send(path_components.push('path').join('_').to_sym)
#        else
#          self.send path_components.push('path').join('_').to_sym,
#            path_components[-2].classify.constantize.first(:conditions => conditions.gsub(/:\s?/, " = ").gsub(/,\s?/, " AND "))
#        end
#      rescue Object => e
#        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
#          "Now, go and add a mapping in #{__FILE__}"
#      end
    end
  end

  def get_person(page_name)
    str_url = ""
    if page_name.include? "edit"
      if page_name.include? "kesehatan"
        cond = page_name.gsub("edit kesehatan dengan person ","")
        a = "person".classify.constantize.first(:conditions => cond)
        str_url = "/edit_health/#{a.id}"
      else
        cond = page_name.gsub("edit person dengan ","")
        a = "person".classify.constantize.first(:conditions => cond)
        str_url = "/people/#{(a.id)}/edit"
      end
    elsif page_name.include? "tambah"
      str_url = "/people/new"
    else
      cond = page_name.gsub("person dengan ", "")
      a = "person".classify.constantize.first(:conditions => cond)
      str_url = "/people/#{(a.id)}"
    end
    return str_url
  end

  def get_memorandums_violations(page_name)
    str_url = ""
    unless page_name.include? "SP"
      if page_name.include? "edit"
        person_cond = page_name.gsub("edit pelanggaran dengan id =1 dan ", "")
        person = "person".classify.constantize.first(:conditions => person_cond)

        temp_cond = page_name.gsub("edit pelanggaran dengan ","")
        violation_cond = temp_cond.gsub(' dan employee_identification_number = "11"',"")
        violations = person.violations.all(:conditions =>violation_cond).first
        str_url = "memorandums/#{violations.id}/edit?pers_id=#{person.id}"
      else
        cond = page_name.gsub("tambah pelanggaran dengan ", "")
        person = "person".classify.constantize.first(:conditions => cond)
        str_url = "/memorandums/new?pers_id=#{person.id}"
      end
    else
      if page_name.include? "edit"
        person_cond = page_name.gsub("edit SP dengan ","")
        person = "person".classify.constantize.first(:conditions => person_cond)
        str_url = "memorandums/#{person.id}/edit"
      elsif page_name.include? "tambah"
        str_url = "/memorandums/new"
      else
        str_url = "/memorandums"
      end
    end
    return str_url
  end

  def get_accidents(page_name)
    str_url = ""
    unless page_name.include?("kecelakaan kerja")
      if page_name.include? "edit"
        person_cond = page_name.gsub("edit kecelakaan dengan id =1 dan ", "")
        person = "person".classify.constantize.first(:conditions => person_cond)

        temp_cond = page_name.gsub("edit kecelakaan dengan ","")
        accident_cond = temp_cond.gsub(' dan employee_identification_number = "11"',"")

        accidents = person.accidents.all(:conditions => accident_cond ).first
        str_url = "/job_accidents/#{accidents.id}/edit?pers_id=#{person.id}"
      else
        cond = page_name.gsub("tambah kecelakaan dengan ", "")
        person = "person".classify.constantize.first(:conditions => cond)
        str_url = "/job_accidents/new?pers_id=#{person.id}"
      end
    else
      if page_name.include?("tambah")
        str_url = "/job_accidents/new"
      elsif page_name.include?("edit")
        person_cond = page_name.gsub("edit kecelakaan kerja dengan ","")
        person = "person".classify.constantize.first(:conditions => person_cond)
        str_url = "/job_accidents/#{person.id}/edit"
      else
        str_url = "/job_accidents"
      end      
    end
    return str_url
  end

  def get_gaji(page_name)
    str_url = ""
    if page_name.include?("master")
      str_url = "/salary_master_datas"
      if page_name.include?("edit")
        gaji_cond = page_name.gsub("edit master gaji dengan ","")
        salary_master_data = "salary_master_datas".classify.constantize.first(:conditions => gaji_cond)
        str_url = "/salary_master_datas/#{salary_master_data.id}/edit"
      end
    elsif page_name.include?("data")
      str_url = "/salaries"
      if page_name.include?("hitung")
        str_url = "/salaries/new"
      end
    end    
    return str_url
  end

  def get_histories(page_name)
    str_url = ""
    cond = page_name.gsub("riwayat dengan ", "")
    person = "person".classify.constantize.first(:conditions => cond)
    str_url = "/history/1?tab=0"
    return str_url
  end
end

World(NavigationHelpers)
