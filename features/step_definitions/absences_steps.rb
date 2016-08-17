Maka /^pengguna dapat melihat (\d+) buah record absensi$/ do |num|
  Presence.who_is_working(32, Date.today, Date.today).count.should == num.to_i
end

Ketika /^pengguna mengisikan filter tanggal$/ do
  visit("/absences", :get, {:date => Date.yesterday.strftime("%Y-%m-%d")})
end

Dengan /^Inisialisasi data absensi$/ do
  require Rails.root.join('db','absensi_seeds')
end
