class AddNetWorktimeToPresences < ActiveRecord::Migration
  def self.up
    add_column :presences, :net_worktime, :float

    Presence.reset_column_information
    company_ids = User.all.map(&:company_id).uniq
    company_ids.each do |company_id|
      presences = Presence.all(:conditions => ['company_id = ?', company_id])
      hr_setting = HrSetting.find_by_company_id(company_id)
      updates = []
      presences.each do |presence|
        presence_details = presence.presence_details
        unless presence_details.blank?
          first_detail = presence_details.first
          last_detail = presence_details.last
          if first_detail == last_detail
            if presence.presence_length_in_hours.blank? && first_detail.end_working && first_detail.start_working
              presence_length_in_hours = (first_detail.end_working - first_detail.start_working)/3600.to_f
              net_worktime = ((presence_length_in_hours * 60 - presence.break_length_in_minutes) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
              updates.push "UPDATE presences SET `presence_length_in_hours` = #{presence_length_in_hours}, `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
            elsif presence.presence_length_in_hours
              net_worktime = ((presence.presence_length_in_hours * 60 - presence.break_length_in_minutes) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
              updates.push "UPDATE presences SET `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
            else
              net_worktime = 0.0
              updates.push "UPDATE presences SET `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
            end
          elsif presence.is_acted_upon?(24)
            if presence.presence_length_in_hours.blank? && last_detail.end_working && first_detail.start_working
              worklength = (last_detail.end_working - first_detail.start_working)/60
              net_worktime = ((worklength - presence.break_length_in_minutes) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
            elsif presence.presence_length_in_hours
              net_worktime = ((presence.presence_length_in_hours * 60 - presence.break_length_in_minutes) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
              updates.push "UPDATE presences SET `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
            else
              net_worktime = 0.0
            end
            updates.push "UPDATE presences SET `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
          else
            net_worktime = (presence.presence_length_in_hours.to_f * 60 / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
            updates.push "UPDATE presences SET `net_worktime` = #{net_worktime} WHERE `id` = #{presence.id}"
          end
        end
      end
      unless updates.blank?
        Presence.transaction do
          updates.each do |update|
            Presence.connection.execute update
          end
        end
      end
    end
  end

  def self.down
    remove_column :presences, :net_worktime
  end
end
