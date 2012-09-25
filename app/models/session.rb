class Session < ActiveRecord::Base
  attr_accessible :time, :user_id
  belongs_to :user
  
  self.per_page = 5
end
