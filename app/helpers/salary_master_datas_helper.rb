module SalaryMasterDatasHelper
  def get_gapok_and_current_date(salary_master_data)
    salary_master_data = SalaryMasterData.find(salary_master_data.id)
    gaji = salary_master_data.valid_from.to_s
    gaji = salary_master_data.created_at.to_s if gaji.blank?
    return {:basic_salary => salary_master_data.basic_salary, :valid_from => gaji}
  end
end
