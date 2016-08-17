# language: id

Fitur: show dan edit jabatan
  Sebagai superadmin
  Saya dapat melihat dan mengedit detail jabatan

 Skenario: list jabatan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "01/12/2011 s/d -"
    Dan saya seharusnya melihat "Anggota"
    Dan saya seharusnya melihat "Accounting"

 Skenario: show jabatan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "01/12/2011"
    Maka saya seharusnya melihat "Detail Jabatan"
    Dan saya seharusnya melihat "Anggota"
    Dan saya seharusnya melihat "Accounting"

Skenario: edit jabatan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "01/12/2011"
    Dan saya klik "Edit"
    Dan saya mengisi "employment_employment_start" dengan "27/01/2012"
    Dan saya mengisi "employment_department_id" dengan "602"
    Dan saya mengisi "employment_work_division_id" dengan "3116"
    Dan saya mengisi "employment_position_id" dengan "122"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "27/01/2012"
    Dan saya seharusnya melihat "Colour Kitchen"
    Dan saya seharusnya melihat "Foreman"
    Dan saya seharusnya tidak melihat "Anggota"
    Dan saya seharusnya tidak melihat "Accounting"