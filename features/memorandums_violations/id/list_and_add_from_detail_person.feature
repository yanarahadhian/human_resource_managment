# language: id

Fitur: tambah pelanggaran
  Sebagai superadmin
  Saya dapat manambah pelanggaran

 Skenario: list pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 pelanggaran berdasarkan person dengan employee_identification_number = "11"

 Skenario: tambah pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke tambah pelanggaran dengan employee_identification_number = "11"
    Dan saya mengisi "violation_violation_category" dengan "Ringan"
    Dan saya mengisi "violation_occurence_date" dengan "13/01/2012"
    Dan saya mengisi "violation_action_taken" dengan "SP1"
    Dan saya mengisi "violation_active_until" dengan "14/01/2012"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 4 pelanggaran berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Ringan"
    Dan saya seharusnya melihat "SP1 sampai 2012-01-14"