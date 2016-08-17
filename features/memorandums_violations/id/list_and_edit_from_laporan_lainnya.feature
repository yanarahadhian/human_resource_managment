# language: id

Fitur: edit SP
  Sebagai superadmin
  Saya dapat mengedit pelanggaran

 Skenario: list SP
    Dengan saya telah login 
    Ketika saya berkunjung ke SP
    Maka saya seharusnya melihat "Surat Peringatan"
    Dan saya seharusnya melihat "Nungky Selection"
    Dan saya seharusnya melihat "SP1"
    Dan saya seharusnya melihat "19/09/2011"

Skenario: edit SP
    Dengan saya telah login
    Ketika saya berkunjung ke edit SP dengan id =1 
    Dan saya mengisi "violation_occurence_date" dengan "01/09/2011"
    Dan saya mengisi "violation_action_taken" dengan "SP2"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke SP
    Maka saya seharusnya tidak melihat "19/09/2011"
    Dan saya seharusnya melihat "01/09/2011"