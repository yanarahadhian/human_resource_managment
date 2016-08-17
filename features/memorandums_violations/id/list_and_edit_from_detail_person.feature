# language: id

Fitur: edit pelanggaran
  Sebagai superadmin
  Saya dapat mengedit pelanggaran

 Skenario: list pelatihan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Data Pelanggaran"
    Dan saya seharusnya melihat "SP1 sampai 2011-12-19"

 Skenario: edit pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke edit pelanggaran dengan id =1 dan employee_identification_number = "11"
    Dan saya mengisi "violation_active_until" dengan "31/12/2011"
    Dan saya menekan "Simpan"    
    Maka saya seharusnya melihat "SP1 sampai 2011-12-31"
    Dan saya seharusnya tidak melihat "SP1 sampai 2011-12-19"