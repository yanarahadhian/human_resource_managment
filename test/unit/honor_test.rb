require 'test_helper'

class HonorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the_truth" do
    assert true
  end

  test "update_last_year_quota" do    
    person = Person.first
    honor = Honor.first
    v = honor.count_salary(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 3500000, format("%.2f",v).to_f
  end

  test "count_overtimes_with_overtime_and_goverment_role" do
    person = Person.first
    honor = Honor.first
    update_hr_seting_company_overtime(person, 0)
    count_overtimes = honor.count_overtimes(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 2, count_overtimes[:total_overtime_hours].to_i
    assert_equal 4, count_overtimes[:total_overtime_modifiers].to_i
    v = count_overtimes[:total_overtime]
    assert_equal 80924.86, format("%.2f",v).to_f
  end

  test "count_overtimes_with_overtime_and_prorata" do
    person = Person.first
    honor = Honor.first
    update_hr_seting_company_overtime(person, 1)
    count_overtimes = honor.count_overtimes(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 2, count_overtimes[:total_overtime_hours].to_i
    assert_equal 0, count_overtimes[:total_overtime_modifiers].to_i
    v = count_overtimes[:total_overtime]
    assert_equal 29166.67, format("%.2f",v).to_f
  end

  test "count_overtimes_without_overtimes" do
    person = Person.first
    honor = Honor.first
    Overtime.delete_all
    count_overtimes = honor.count_overtimes(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal ({:total_overtime_hours=>0.0, :total_overtime=>0, :total_overtime_modifiers=>0}), count_overtimes
  end

  test "count_premiums" do
    person = Person.first
    honor = Honor.first
    v = honor.count_premiums(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 90000, format("%.2f",v).to_f
  end

  test "count_jamsostek_cut" do
    person = Person.first
    honor = Honor.first    
    v = honor.count_jamsostek_cut(person)
    assert_equal 70000.0, format("%.2f",v).to_f
  end

  test "count_jamsostek_house_cut" do
    honor = Honor.first
    v = honor.count_jamsostek_house_cut
    assert_equal 10000.0, v.to_f
  end

  test "count_jamsostek_insurance" do
    honor = Honor.first
    v = honor.count_jamsostek_insurance
    assert_equal 15000.0, v.to_f
  end
  
  test "count_salary_cut" do
    person = Person.first
    honor = Honor.first
    v = honor.count_salary_cut(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 479333.0, format("%.2f",v).to_f
  end

  test "count_total_premium_cut" do
    person = Person.first
    honor = Honor.first
    v = honor.count_total_premium_cut(person, "2012-03-01".to_date, "2012-03-31".to_date)
    assert_equal 246000.0, format("%.2f",v).to_f
  end

  test "count_gross_income_with_person_thr" do
    honor = Honor.first
    v = honor.count_gross_income
    assert_equal 3500000, format("%.2f",v).to_f
  end

  test "count_gross_income_without_person_thr" do
    honor = Honor.first
    honor.update_attribute(:is_thr, false)
    v = honor.count_gross_income
    assert_equal 3139833.67, format("%.2f",v).to_f
  end

  test "count_position_expenses" do
    honor = Honor.first
    honor.update_attribute(:is_thr, false)
    v = honor.count_position_expenses
    assert_equal 156991.68, format("%.2f",v).to_f
  end

  test "count_month_net_income_with_last_honor" do
    honor = Honor.first
    honor.update_attribute(:is_thr, false)
    v = honor.count_month_net_income
    assert_equal 2982841.98, format("%.2f",v).to_f
  end

  test "count_month_net_income_without_last_honor" do
    honor = Honor.first
    v = honor.count_month_net_income
    assert_equal 3216541.99, format("%.2f",v).to_f
  end

  test "count_month_net_income_without_work_contract" do
    honor = Honor.first
    honor.person.work_contracts.delete_all
    v = honor.count_month_net_income
    assert_equal honor.gross_income, format("%.2f",v).to_f
  end

  test "count_year_net_income_with_person_thr" do
    honor = Honor.first
    v = honor.count_year_net_income
    assert_equal honor.month_net_income, format("%.2f",v).to_f
  end

  test "count_year_net_income_without_person_thr" do
    honor = Honor.first
    honor.update_attribute(:is_thr, false)
    v = honor.count_year_net_income    
    assert_equal 35794092.0, format("%.2f",v).to_f
  end

  test "count_ptkp" do
    honor = Honor.first
    v = honor.count_ptkp
    assert_equal 15840000.0, format("%.2f",v).to_f
  end

  test "count_pkp_without_daily_work_contract" do
    honor = Honor.first
    v = honor.count_pkp
    assert_equal 22758000.0, format("%.2f",v).to_f
  end

  test "count_pkp_with_daily_work_contract" do
    honor = Honor.first
    wc = honor.person.current_work_contract
    wc.update_attribute(:is_daily_employee, true)
    v = honor.count_pkp
    assert_equal -12454000.0, format("%.2f",v).to_f
  end

  test "count_pph_indebted_per_year_with_npwp" do
    honor = Honor.first
    v = honor.count_pph_indebted_per_year
    assert_equal 1137900.0, format("%.2f",v).to_f
  end

  test "count_pph_indebted_per_year_without_npwp" do
    honor = Honor.first
    honor.person.update_attribute(:no_npwp, nil)
    v = honor.count_pph_indebted_per_year
    assert_equal 1365480.0, format("%.2f",v).to_f
  end

  test "count_pph_indebted_per_month_without_last_honor" do
    honor = Honor.first
    v = honor.count_pph_indebted_per_month
    assert_equal 113790.0, format("%.2f",v).to_f
  end

  test "count_pph_indebted_per_month_with_last_honor" do
    honor = Honor.first
    honor.update_attribute(:is_thr, true)
    v = honor.count_pph_indebted_per_month
    assert_equal 0, format("%.2f",v).to_f
  end

  test "count_take_home_pay_with_person_thr" do
    honor = Honor.first
    v = honor.count_take_home_pay
    assert_equal 3272043.67, format("%.2f",v).to_f
  end

  test "count_take_home_pay_without_person_thr" do
    honor = Honor.first
    honor.update_attribute(:is_thr, false)
    v = honor.count_take_home_pay    
    assert_equal 2961691.67, format("%.2f",v).to_f
  end

  test "rounded" do
    honor = Honor.first
    v = honor.rounded(honor.final_take_home_pay)
    assert_equal 3272000, v[:rounded]
    assert_equal -43, v[:rounding_of]
  end

  test "set_salary_with_sequential_salary_cut" do
    honor = Honor.first
    v = honor.count_take_home_pay
    assert_equal 2961691.67, format("%.2f",v).to_f
  end

 private

  def update_hr_seting_company_overtime(person, data)
    hr_setting = HrSetting.find_by_company_id(person.company_id)
    hr_setting.update_attribute(:is_company_overtime,data)
  end
end