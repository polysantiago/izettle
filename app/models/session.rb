# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Session < ActiveRecord::Base
  attr_accessible :time, :user_id
  
  belongs_to :user
  
  self.per_page = 5
end
