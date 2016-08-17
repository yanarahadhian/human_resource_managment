# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def user_nav_active(controller, first=false)
    if first && params[:controller] == controller
      return 'class="first active"'
    elsif params[:controller] == controller
      return 'class="active"'
    else
      return ''
    end
  end

  def user_tab_active(controller, first=false)
    if params[:controller] == controller
      return 'selected'
    else
      return nil
    end
  end

  def select_options(objs, custom=false, titleize=true)
    if titleize
      opt = objs.map{|obj| [obj.name.titleize, obj.id]}
    else
      opt = objs.map{|obj| [obj.name, obj.id]}
    end
    opt << ['Custom', 'custom'] if custom
    return opt
  end

  def person_root_link_col(person)
    "<ul class='tabs' id='profile_tabs'>
      <li view='wall' class='selected'>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pribadi</div></div>', person_path(person.id), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall'>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pekerjaan</div></div>',  person_employments_path(person.id), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def person_link_col(person)
    "<ul class='tabs' id='profile_tabs'>
      <li view='wall' class=#{user_tab_active('people')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Basic</div></div>', person_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('addresses')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Alamat</div></div>', person_addresses_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('families')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Keluarga</div></div>', person_families_path(person), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def emp_root_link_col(person)
    "<ul class='tabs' id='profile_tabs'>
      <li view='wall'>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Basic</div></div>', person_path(person.id), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class='selected'>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pekerjaan</div></div>',  person_employments_path(person.id), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def emp_link_col(person)
    "<ul class='tabs' id='profile_tabs'>
      <li view='wall' class=#{user_tab_active('employments')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Jabatan</div></div>', person_employments_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('trainings')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pelatihan</div></div>', person_trainings_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('violations')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pelanggaran</div></div>', person_violations_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('accidents')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Kecelakaan</div></div>', person_accidents_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('awards')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Penghargaan</div></div>', person_awards_path(person), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def emp_form_col(person)
    "<ul class='tabs' id='profile_tabs'>
      <li view='wall' class=#{user_tab_active('employments')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Jabatan</div></div>', person_employments_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('trainings')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pelatihan</div></div>', person_trainings_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('violations')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Pelanggaran</div></div>', person_violations_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('accidents')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Kecelakaan</div></div>', person_accidents_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('awards')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Penghargaan</div></div>', person_awards_path(person), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def person_form_col(person)
     "<ul class='tabs' id='profile_tabs'>
      <li view='wall' class=#{user_tab_active('people')||user_tab_active('educations')||user_tab_active('experiences')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Basic</div></div>', person_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('addresses')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Alamat</div></div>', person_addresses_path(person), :class=>'tab_link profile_tab' }
      </li>
      <li view='wall' class=#{user_tab_active('families')}>
        #{ link_to '<div class=\'app_tab_header\'><div class=\'app_tab_icon\'>&nbsp;</div><div class=\'app_tab_title\'>Data Keluarga</div></div>', person_families_path(person), :class=>'tab_link profile_tab' }
      </li>
    </ul>"
  end

  def zero_to_now(value)
    value == 0 ? 'sekarang' : value.to_s
  end

  def test(person)
    "<h2><p>" +
      check_current_page('people', 'Data Pribadi', person_path(person)) + ' | ' +
      check_current_page('employments','Data Pekerjaan', person_employments_path(person)) + ' | ' +
      check_current_page('addresses', 'Data Alamat', person_addresses_path(person)) + ' | ' +
      check_current_page('families', 'Data Keluarga', person_families_path(person)) + "</h2></p>"
  end

  def user_fullname(obj)
    #unless session[:user].blank?
    #  return session[:user]["firstname"] + " " + session[:user]["lastname"]
    #end
    unless session[:people].blank?
      return session[:people]["full_name"]
    end
  end

  def check_privilage(section)
    return true
    @privilage = Correlation.find(:first, :conditions => ["(correlations.role_id = ? or correlations.group_role_id = ?) and sections.controller_name = ?", current_user.role.id, current_user.role.group_role_id, section], :joins => [:feature, [:feature => :section]])
    if @privilage
      return true
    else
      return false
    end
  end

  def check_privilage_detail(section, action)
    return true
    @privilage = Correlation.find(:first, :conditions => ["(correlations.role_id = ? or correlations.group_role_id = ?) and sections.controller_name = ? and actions.action_name = ?", current_user.role.id, current_user.role.group_role_id, section, action], :joins => [:feature, [:feature => :section], [:feature => :action]])
    if @privilage
      return true
    else
      return false
    end
  end

  def format_currency(money)
    number_to_currency(money.to_i, :unit => "Rp. ", :separator => ",", :delimiter => ".", :format => "%u %n", :precision => 0) + ",-" unless money.blank?
  end

  def format_no_currency_with_precision(money)
    number_to_currency(money.to_i, :separator => ",", :delimiter => ".", :format => "%n", :precision => 0) + ",-" unless money.blank?
  end

  def format_no_currency(money)
    number_to_currency(money.to_i, :separator => ",", :delimiter => ".", :format => "%n", :precision => 0) + ",-" unless money.blank?
  end

  def format_paginate(current_page, per_page, count)
    if current_page == 1
      a = current_page
      b = per_page
      if b > count
        b = count
      end
      return {:a => a, :b => b}
    else
      b = current_page * per_page
      a = b - (per_page-1)
      if b > count
        b = count
      end
      return {:a => a, :b => b}
    end
  end

  def format_paginate1(object, per_page, count, action = "index")
    if object.current_page == 1
      a = object.current_page
      a = 0 if object.count == 0
      b = per_page
      if b > count
        b = count
      end
      return {:a => a, :b => b, :paginate => attribute_will_paginate(object, action)}
    else
      b = object.current_page * per_page
      a = b - (per_page-1)
      if b > count
        b = count
      end
      return {:a => a, :b => b, :paginate => attribute_will_paginate(object, action)}
    end
  end

  def attribute_will_paginate(object, action)
    will_paginate object, {
       :class          => 'pages',
       :renderer => 'WillPaginate::MyLinkRenderer',
       :previous_label => '',
       :next_label     => '',
       :inner_window   => 5,
       :outer_window   => 1,
       :separator      => ' ',
       :param_name     => :page,
       :params         => {:action => action},
       :page_links     => false,
       :container      => true
    }
  end
  

  def get_url_person_back(item)
    unless item.blank?
      return "#demosi" if item == "list_demosi"
      return "#absences" if item == "daily_index_table" || item == "monthly_index_table"
      return "##{item}" 
    else
      return "#person_index"
    end
  end

  def sortablecol(column1, column2, direction,name=nil)
    if column1 == column2
      rev = reverse_direction(direction)
      return "sortResult#{name}('#{column1}','#{rev}')"
    else
      return "sortResult#{name}('#{column1}','asc')"
    end
  end

  def reverse_direction(d)
    d == "asc" ? "desc" : "asc"
  end

  def logo_company(file)
    logo = file.include?('http') ? "#{file}" : "appschef logo.png"
    return image_tag(logo, :height => '80')
  end

  def determine_salary(person, salary)
    if salary == 0
      if !person.current_salary.blank?
        return person.current_salary.salary
      elsif person.current_salary_data_master.blank?
        return person.current_salary_data_master.basic_salary
      end
    else
      return salary
    end
  end

  private

  def check_current_page(controller, text, path)
    params[:controller] == controller ? text : link_to(text, path)
  end

  def main_menu_class(controller, actions=nil)
    a = "UIFilterList_Item"
    if params[:controller] == controller
      if actions.nil? && !['show_pending', 'pending'].include?(params[:action])
        a = "UIFilterList_Item selected"
      elsif !actions.nil?
        if actions.include?(params[:action]) && current_user.has_role?(["superadmin", "supervisor_sdm"])
          a = "UIFilterList_Item selected"
        end
      end
    end
    return a
  end

  def class_date(stringdate)

    if stringdate.class == 'Date'
      newdate = dt.strftime("%d %b %Y")
    else
      year = stringdate.split('-')[0]
      month = stringdate.split('-')[1]
      day = stringdate.split('-')[2]

      dt = Time.mktime(year,month,day)
      newdate = dt.strftime("%d %b %Y")
    end
  end

  def people_count
    return Person.count
  end

  def star(type)
    if type != 'keluar'
      return " <span id='star'>*</span>"
    end
  end

  def current_platform_user
    @current_platform_user ||= User.get_platform_user(session[:platform_token]) if session[:platform_token]
  end


  def url_back_accident(person_id)
    if person_id
      return "#people/#{person_id}/employments?tab=4"
    else
      return "#job_accidents"
    end
  end

  def url_back_sp(person_id)
    unless person_id.blank?
      return "#people/#{person_id}/employments?tab=3"
    else
      return "#memorandums"
    end
  end

  # Converting seconds to year
  # 1 year = 31,536,000 sec
  def seconds_to_year(second)
    return (second/31536000).to_i
  end

  def add_task_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tasks, :partial => 'work_contracts/row_work_contract', :object => Task.new
    end
  end

 def remove_child_link(name, f)
    f.hidden_field(:_delete) + link_to(name, "javascript:void(0)", :class => "remove_child icons delete-icon")
  end

  def add_child_link(name, association)
    link_to(name, "javascript:void(0)", :class => "add_child grey_button_notext add_barang", :"data-association" => association, :id=>"add_barang")
  end

  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f

    content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :locals => {options[:form_builder_local] => f})
      end
    end
  end

  def second_to_days(sec)
    lama = ""
    lama_tahun = 60*60*24*30*12
    lama_bulan = 60*60*24*30
    if sec > 0
      tahun = (sec/ lama_tahun).to_i
      if tahun == 0
        month = (sec / lama_bulan).to_i
        lama = "#{month} bulan"
      else
        month = ((sec % (lama_tahun))/(lama_bulan)).to_i
        lama = "#{tahun} tahun, #{month} bulan"
      end
    end
    return lama
  end

  def count_of_work_contrat(id)
    count = WorkContract.all(:conditions => "person_id=#{id}").count
    return count
  end

  def count_of_work_penghargaan(id)
    count = Award.all(:conditions => "person_id=#{id}").count
    return count
  end

  def get_emp_baru(prev_id)
    emp_baru = nil
    unless Employment.find(prev_id).blank?
      emp_baru = Employment.find(prev_id)
    end
    return emp_baru
  end

  def value_year_for_combo
    t = Time.now
    first = t.year-15
    year_now = t.year
    last = t.year+1
    return {:first => first, :last=>last, :year_now => year_now}
  end

  def get_year_for_combo(params)
    a = ""        
    year = value_year_for_combo
    for i in year[:first]..year[:last] do
      sel = ""
      if params[:filter].blank?        
        sel = " selected='selected'" if i == year[:year_now]
      else
        sel = " selected='selected'" if i == params[:filter][:tahun].to_i
      end
      a += "<option value=\"#{i}\"#{sel}>#{i}</option>"
    end
    return a
  end

  def value_month_for_combo(m,params = nil)
    a = ""
    if params.blank?
      a = "selected='selected'" if m == Time.now.month
    else
      if params[:filter].blank?
        a = "selected='selected'" if m == Time.now.month
      else
        a = "selected='selected'" if m == params[:filter][:bulan].to_i
      end      
    end
    return a
  end

  def count_karyawan_bagian_by_department(id)
    emp = Employment.find(:all, :conditions => ["department_id = ? AND (change_from_before != ? OR change_from_before is NULL) AND people.latest_employment_id=employments.id", id, 'terminasi'], :include => :person)
    personel = []
    emp.each do |e|
      if e.current_employment?
        person = e.current_employment_people
        personel << person if person.company_id == current_company_id
      end
    end
    return {:people => personel.count}
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = sort_direction == "asc" ? "desc" : "asc"
    if params[:action]=="index"
      link_to title.upcase == "NIK"? title.upcase : title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
    else
      link_to title.upcase == "NIK"? title.upcase : title, act_cont.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
    end
  end

  def act_cont
    act = session[:url_act]
    cont = "people"
    if session[:url_act]=="promotions"
      act = "index"
      cont = "promotions"
    elsif session[:url_act]=="person_index"
      act = "index"
    end
    return {:action => act, :controller => cont}
  end

  def get_combobox(array, param, key)
    a = "<option value="">Pilih</option>"
    array.each do |x|
      sel = ""
      if param
        sel = " selected='selected'" if x.display.downcase == param[key]
      end
      a << "<option value='#{x.display}'#{sel}>#{x}</option>"
    end
    return a
  end

end
