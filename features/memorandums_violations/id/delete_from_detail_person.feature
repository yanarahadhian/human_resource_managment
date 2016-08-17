# language: id

Fitur: hapus pelanggaran
  Sebagai superadmin
  Saya dapat menghapus pelanggaran

 Skenario: list pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 pelanggaran berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "SP1 sampai 2011-12-19"

 Skenario: hapus pelanggaran
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada pelanggaran dengan id = "1"
    Dan saya menghapus pelanggaran
    Maka saya seharusnya memiliki 2 pelanggaran berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "SP1 sampai 2011-12-19"