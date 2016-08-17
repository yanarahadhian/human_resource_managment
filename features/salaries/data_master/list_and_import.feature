# language: id

Fitur: Daftar master gaji
  Sebagai superadmin
  Saya dapat melihat master gaji

 Skenario: list master gaji
    Dengan saya telah login
    Ketika saya berkunjung ke gaji master
    Maka saya seharusnya memiliki 1 data gaji master
    Dan Maka saya seharusnya memiliki 1 data gaji master salary

 Skenario: import master gaji
    Dengan saya telah login
    Dan saya berada di gaji master
    Ketika saya upload a file master "data_master_gaji.xls"
    Dan saya berkunjung ke gaji master
    Maka saya seharusnya memiliki 2 data gaji master
    Dan Maka saya seharusnya memiliki 2 data gaji master salary