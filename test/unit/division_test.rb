require 'test_helper'

class DivisionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "get_division_id_by_jumlah_karyawan" do
    person = Person.first
    division = Division.first
    v = Division.by_company(company_id).collect(&:id)
  end

  test "groups_count" do
    person = Person.first
    division = Division.first
    v = Division.work_groups.count
  end

  test "personel" do
    person = Person.first
    division = Division.first
    v = Division.person.full_name
  end
end
