puts "===== Populating Contact Type for CGNP ====="
# Populating Contact Type for CGNP
ContractType.create_or_update(:id => 1, :company_id => 123, :contract_type_name => 'Tetap Harian')
ContractType.create_or_update(:id => 2, :company_id => 123, :contract_type_name => 'Tetap Bulanan')
ContractType.create_or_update(:id => 3, :company_id => 123, :contract_type_name => 'Kontrak Harian')
ContractType.create_or_update(:id => 4, :company_id => 123, :contract_type_name => 'Kontrak Bulanan')