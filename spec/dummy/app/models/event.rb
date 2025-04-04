# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  name        :string
#  event_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  body        :text
#  location_id :bigint
#
class Event < ApplicationRecord
  has_rich_text :body

  belongs_to :location, optional: true

  has_one_attached :profile_photo
  has_one_attached :cover_photo

  def first_user
    User.first
  end

  def attendees
    raise "Test array resource, this method should not be called"
  end
end
