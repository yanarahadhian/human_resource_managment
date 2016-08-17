# language: id

Fitur: Hapus pelatihan
  Sebagai superadmin
  Saya dapat menghapus pelatihan

 Skenario: list pelatihan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 pelatihan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Jack fernandes"

Skenario: hapus pelatihan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada pelatihan dengan id = "1"
    Dan saya menghapus pelatihan
    Maka saya seharusnya memiliki 2 pelatihan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Jack fernandes"