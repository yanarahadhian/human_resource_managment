require 'spec_helper'
require 'db/cucumber_seeds.rb'

describe Presence do
  before(:each) do
    @presence_start = Time.parse([Date.today.strftime("%Y-%m-%d"),"08:00:00"].join(" "))
    @presence_end = Time.parse([Date.today.strftime("%Y-%m-%d"),"17:00:00"].join(" "))
    @person = Person.find(1)
  end

  it "should be login successfully for person presence without schedule" do
    Presence.login(@person,@presence_start)
    presence = @person.presences.find_by_presence_date(Date.today)
    presence.should_not.blank?
    presence.presence_date.should == Date.today
    presence.presence_details.should_not.blank?
    presence.presence_details.first.start_working.should == @presence_start
    presence.presence_details.first.end_working.should.blank?
  end

  it "should be logout successfully on presence without login and without schedule" do
    Presence.logout(@person,@presence_end)
    presence = @person.presences.find_by_presence_date(Date.today)
    presence.should_not.blank?
    presence.presence_date.should == Date.today
    presence.presence_details.should_not.blank?
    presence.presence_details.first.end_working.should == @presence_end
    presence.presence_details.first.start_working.should.blank?
  end

  it "should be login then logout successfully on presence without schedule" do
    time_in_minutes = (@presence_end - @presence_start) / 60
    Presence.login(@person,@presence_start)
    Presence.logout(@person,@presence_end)
    presence = @person.presences.find_by_presence_date(Date.today)
    presence.should_not.blank?
    presence.presence_date.should == Date.today
    presence.person.should == @person
    presence.presence_details.should_not.blank?
    presence.presence_details.count.should == 1
    presence.presence_details.first.start_working.should == @presence_start
    presence.presence_details.first.work_session_length_in_minutes.should == time_in_minutes
    presence.presence_details.first.end_working.should == @presence_end
    presence.presence_length_in_hours.should == time_in_minutes / 60
  end
end
