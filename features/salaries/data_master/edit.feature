# language: id

Fitur: Edit master gaji
  Sebagai superadmin
  Saya dapat mengedit master gaji

 Skenario: list master gaji
    Dengan saya telah login
    Ketika saya berkunjung ke gaji master
    Maka saya seharusnya melihat "Rp. 30.000.000,-"
    Dan saya seharusnya tidak melihat "Rp. 4.000.000,-"
    Dan Maka saya seharusnya memiliki 1 data gaji master salary

 Skenario: edit master gaji
    Dengan saya telah login
    Ketika saya berkunjung ke edit master gaji dengan id=1
    Dan saya mengisi "ui-date" dengan "17/02/2012"
    Dan saya mengisi "salary_master_data_basic_salary" dengan "4000000"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke gaji master
    Maka saya seharusnya melihat "Rp. 4.000.000,-"
    Dan saya seharusnya tidak melihat "Rp. 30.000.000,-"
    Dan Maka saya seharusnya memiliki 2 data gaji master salary