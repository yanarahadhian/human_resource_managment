class TrainingsController < ApplicationController
#  before_filter :login_required
  before_filter :trained_as_values, :except => [:destroy]
  ssl_required :delete_multiple, :popup_add_training, :popup_detail_training, :cancel_popup_detail, :popup_edit_training, :ajax_person_trained_in_name, :ajax_training_person_trained_in
  def index
    @person = Person.find(params[:person_id])
    @employments = @person.employments
    @trainings = @person.trainings.find(:all, :order => 'training_start DESC, training_end DESC')
    render :layout => false
  end
  
  def new
    @person = Person.find(params[:person_id])
    @training = @person.trainings.new
    render :layout => false
  end

  def create
    @person = Person.find(params[:person_id])
    @training = Training.new(params[:training].merge({:person_id => params[:person_id]}))
    if @training.save
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}/employments?tab=2&save=create_trainings';</script></body></html>"
    else
      @sign = "gagal"
      render :layout=> false, :action => :popup_add_training
    end
  end

  def edit
    @person = Person.find(params[:person_id])
    @training = Training.find(params[:id])
    render :layout => false
  end

  def update    
    @person = Person.find(params[:person_id])
    @training = Training.find(params[:id])
    if @training.update_attributes(params[:training])
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}/employments?tab=2&save=update_trainings';</script></body></html>"
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      @sign = "gagal"
      render :layout=> false, :action => :popup_detail_training
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data pelatihan gagal dihapus!"
    unless params[:ids].blank?
      @training = Training.find(params[:ids])
      @training.each do |training|
        training.destroy
      end
      flash.now[:notice] = "Data pelatihan berhasil dihapus!"
    end
    @person = Person.find(params[:person_id])
    @trainings = @person.trainings.find(:all, :order => 'training_start DESC, training_end DESC')
    reload_page('info_pelatihan','trainings/list_trainings',"people/#{params[:person_id]}/employments?tab=2")
  end


  def popup_add_training
    @person = Person.find(params[:person_id])
    @training = @person.trainings.new
    render :layout => false
  end

  def popup_detail_training
    @person = Person.find(params[:person_id])
    @training = Training.find(params[:id])
    render :layout => false
  end

  def cancel_popup_detail
    @person = Person.find(params[:person_id])
    @training = Training.find(params[:id])
    reload_page('div_edit_training_form','edit_form')
  end

  def popup_edit_training
    @person = Person.find(params[:person_id])
    @training = Training.find(params[:id])
    render :layout => false
  end

  def ajax_person_trained_in_name
    trainings = Training.all(:conditions => ['person_trained_in LIKE ? OR person_trained_in LIKE ? OR person_trained_in LIKE ? ', params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q]])
    render :text => proc { |response, output| trainings.each do |list| output.write("#{list.person_trained_in}") end }
  end

  def ajax_training_person_trained_in
    people = Person.find(:all, :conditions => ['( full_name LIKE ? OR full_name LIKE ? OR full_name LIKE ? ) AND id <> ? ', params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q], params[:id]])
    render :text => proc { |response, output| people.each do |person| output.write("#{person.full_name}|#{person.id}\n") end }
  end
  
  private

  def trained_as_values
    @trained_as = Training.find(:all,:select => "distinct person_trained_as").collect{ |training| training.person_trained_as }.join(',')
    @trained_in = Person.all.collect{ |person| person.full_name }.join(',')
  end
  
  def ajax_lists(attribute)
    accidents = Accident.all(:conditions => ["#{attribute} LIKE ? OR #{attribute} LIKE ? OR #{attribute} LIKE ?", params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q]])
    render :text => proc { |response, output| accidents.each do |acc| output.write("#{acc.send(attribute)}|#{acc.id}\n") end }
  end
  
  def reload_page(div_name, page_name, url = nil)
    respond_to do |format|
        format.html {}
        format.js {
          render :update do |page|
            page.replace_html div_name, :partial=> page_name, :object => @people
            page << "$.address.value('#{url}');" unless url.blank?
            page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
            page << "removeNotifyMessage();"
          end
        }
      end
  end
    
end
