# == Schema Information
#
# Table name: warning_memos
#
#  id             :integer(4)      not null, primary key
#  memo_level     :string(255)
#  warning_reason :string(255)
#  warning_date   :date
#  created_at     :datetime
#  updated_at     :datetime
#

class WarningMemo < ActiveRecord::Base
  belongs_to :company
  belongs_to :person
end


