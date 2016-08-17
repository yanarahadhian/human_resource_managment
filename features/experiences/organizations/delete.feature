# language: id

Fitur: Hapus organisasi
  Sebagai superadmin
  Saya dapat melihat menghapus organisasi

 Skenario: list organisasi
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Lembaga bantuan hukum organisations"

 Skenario: hapus organisasi
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada organisasi dengan id = "2"
    Dan saya menghapus organisasi
    Maka saya seharusnya memiliki 0 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Lembaga bantuan hukum organisations"