class ChangeTableNames < ActiveRecord::Migration
  def self.up
    rename_table :shift, :shifts
    rename_table :work_time, :work_times
    rename_table :hr_setting, :hr_settings
    rename_table :overtime, :overtimes
    rename_table :absence, :absences
    rename_table :presence, :presences
    rename_table :presence_detail, :presence_details
    rename_table :absence_type, :absence_types
    rename_table :national_holiday, :national_holidays
    rename_table :join_leave, :join_leaves
    rename_table :employee_leave, :employee_leaves
    rename_table :employee_leave_detail, :employee_leave_details
    rename_table :warning_memo, :warning_memos
    rename_table :premium,:premiums
    rename_table :premium_in_honor, :premium_in_honors
    rename_table :work_contract, :work_contracts
    rename_table :contract_type, :contract_types
    rename_table :employment_type, :employment_types
  end

  def self.down
    rename_table :shifts, :shift
    rename_table :work_times, :work_time
    rename_table :hr_settings, :hr_setting
    rename_table :overtimes, :overtime
    rename_table :absences, :absence
    rename_table :presences, :presence
    rename_table :presence_details, :presence_detail
    rename_table :absence_types, :absence_type
    rename_table :national_holidays, :national_holiday
    rename_table :join_leaves, :join_leave
    rename_table :employee_leaves, :employee_leave
    rename_table :employee_leave_details, :employee_leave_detail
    rename_table :warning_memos, :warning_memo
    rename_table :premiums, :premium
    rename_table :premium_in_honors, :premium_in_honor
    rename_table :work_contracts, :work_contract
    rename_table :contract_types, :contract_type
    rename_table :employment_types, :employment_type
  end
end

