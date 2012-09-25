# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string(255)
#  encrypted_password :string(255)
#  salt               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  admin              :boolean          default(FALSE)
#  registered_on      :datetime
#  last_login         :datetime
#

require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :password, :password_confirmation, :admin, :registered_on, :last_login
  validates_uniqueness_of :email, :message => "Email is already being used"
  
  has_many :sessions  

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence => true, :format => { :with => email_regex }, :uniqueness => { :case_sensitive => false }

  # Automatically create the virtual attribute 'password_confirmation'
  validates :password, :presence => true, :confirmation => true, :length => { :within => 6..8 }

  before_save { |user| user.email = email.downcase }

  # Return true if the user's password matched the submitted password
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  # Static method - For Java developers ;)
  class << self
    def authenticate(email, submitted_password)
      user = find_by_email(email)
      (user && user.has_password?(submitted_password)) ? user : nil
    end
  
    def authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
  end
  
  def encrypt_password
      self.salt = make_salt unless has_password?(password)
      self.encrypted_password = encrypt(password)      
  end  

  private

    def encrypt(string)
      secure_hash("#{self.salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{self.password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
