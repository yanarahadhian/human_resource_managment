# language: id

Fitur: hapus SP
  Sebagai superadmin
  Saya dapat menghapus SP

 Skenario: list SP
    Dengan saya telah login
    Ketika saya berkunjung ke SP
    Maka saya seharusnya memiliki 3 SP

 Skenario: hapus SP
    Dengan saya telah login
    Dan saya berada di SP
    Ketika saya mencentang "myrow[ids][]" pada SP dengan id = "1"
    Dan saya menghapus SP
    Maka saya seharusnya memiliki 2 SP