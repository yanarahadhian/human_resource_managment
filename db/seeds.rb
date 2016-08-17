# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

  Dir[Rails.root.join('db', 'seeds', Rails.env, '*.yml')].sort.each do |seed|
    puts "seeding file #{seed.inspect}"
    documents = YAML.load_file(seed)
    klass = File.basename(seed.split('-').last, '.yml').classify.constantize
    documents.sort.each do |doc|
      puts doc.inspect
      new_record = klass.new(doc.last)
      new_record.save(false)
      puts new_record.inspect
    end
  end

  puts "========== SEEDING DATA.. =========="
  require 'active_record/fixtures'

  puts "========== SEEDING TAX STATUSES.. =========="
  Fixtures.create_fixtures('db/seeds/data', File.basename("tax_statuses.yml", '.*'))

  puts "========== SEEDING WORK TIMES.. =========="
  Fixtures.create_fixtures('db/seeds/data', File.basename("work_times.yml", '.*'))

  puts "========== SEEDING SHIFTS.. =========="
  Fixtures.create_fixtures('db/seeds/data', File.basename("shifts.yml", '.*'))

  puts "======== SEED ABSENCES DATA ========"
  Fixtures.create_fixtures('db/seeds/data', File.basename("absences.yml", '.*'))
  end_date_absence = Date.today
  start_date_absence = end_date_absence - 4.months
  person2 = Person.find(1)
  (start_date_absence..end_date_absence).each do |date|
    if person2.current_employment.shift.daily_schedule(date)
      person2.absences.create(:company_id => 1, :absence_date => date, :absence_type_id => 3, :absence_reason => "Sakit Menahun")
    end
  end

  puts "====== SEED PRESENCES ========"
  Fixtures.create_fixtures('db/seeds/data', File.basename("presences.yml", '.*'))
  presences = Presence.all
  presences.each do |presence|
    if presence.presence_details
      date = presence.presence_date
      start_working = Time.mktime(date.year, date.month, date.day, 8, 0) + (rand(30)+rand(30)).minutes
      end_working = Time.mktime(date.year, date.month, date.day, 11, 50) + (rand(10)+rand(10)).minutes
      work_session_length = (end_working - start_working)/60
      presence.presence_details.create( :start_working => start_working, :end_working => end_working,
                                        :work_session_length_in_minutes => work_session_length )
      start_working = Time.mktime(date.year, date.month, date.day, 12, 50) + (rand(10)+rand(10)).minutes
      presence.break_length_in_minutes = (start_working - end_working)/60
      presence.save
      end_working = Time.mktime(date.year, date.month, date.day, 16, 50) + (rand(20)+rand(20)).minutes
      work_session_length = (end_working - start_working)/60
      presence.presence_details.create( :start_working => start_working, :end_working => end_working,
                                        :work_session_length_in_minutes => work_session_length )
    end
  end

