require 'digest'
class User < ActiveRecord::Base
    has_one :seat,  :dependent => :nullify
	attr_accessor :password
	
  validates :username, :uniqueness => true, 
										:length => { :within => 1..50 }
	validates :password, :confirmation => true,
											 :length => { :within => 4..20 },
                       :presence => true,
                       :if => :password_required?
	validates :fname, :presence => true
	validates :lname, :presence => true

	before_save :encrypt_new_password

  def self.authenticate(username, password)
    user = find_by_username(username)
    return user if user && user.authenticated?(password)
  end

  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  protected
    def encrypt_new_password
      return if password.blank?
      self.hashed_password = encrypt(password)
    end

    def password_required?
      hashed_password.blank? || password.present?
    end

    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end
	def published?
    published_at.present?
  end
											
end
