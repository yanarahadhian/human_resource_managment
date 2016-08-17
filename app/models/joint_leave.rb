# == Schema Information
#
# Table name: joint_leaves
#
#  id         :integer(4)      not null, primary key
#  company_id :integer(4)
#  leave_date :date
#  leave_name :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class JointLeave < ActiveRecord::Base

end


