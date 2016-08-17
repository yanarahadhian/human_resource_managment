# language: id

Fitur: Hapus pendidikan
  Sebagai superadmin
  Saya dapat menghapus pendidikan

 Skenario: list pendidikan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "S1"

 Skenario: hapus pendidikan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada pendidikan dengan id = "1"
    Dan saya menghapus pendidikan
    Maka saya seharusnya memiliki 0 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "S1"