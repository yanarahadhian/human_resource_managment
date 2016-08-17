require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

test "options" do
    person = Person.first
    address = Address.first
    address_type = ['rumah', 'kantor cabang', 'kantor pusat', 'etc']
end

test "last_person_address" do
  person = Person.first
  address = Address.first
  v = Address.last_address_to_str(person, "Jalan Jalak".to_str)
end
