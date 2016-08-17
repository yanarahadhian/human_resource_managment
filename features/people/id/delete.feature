# language: id

Fitur: Daftar people
  Sebagai superadmin
  Saya dapat melihat daftar people

 Skenario: list people
    Dengan saya telah login
    Ketika saya berkunjung ke halaman people
    Maka saya harus memiliki 2 person
    Dan saya seharusnya melihat "Nungky Selection"

 Skenario: list people
    Dengan saya telah login
    Dan saya berada di halaman people
    Ketika saya mencentang "myrow[ids][]" dengan employee_identification_number = "11"
    Dan saya menghapus people
    Maka saya harus memiliki 1 person
    Dan saya seharusnya tidak melihat "Nungky Selection"