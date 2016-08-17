module LeavesHelper
  
  def last_periode(leave) 
    leave = EmployeeLeave.find(:last, :conditions => ['person_id = ? AND created_at = ?', leave.person_id, leave.created_at], :select => 'leave_date')
    return leave.leave_date.strftime("%d/%m/%Y")
  end
end
