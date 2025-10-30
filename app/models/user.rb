class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, if: :password_required?

  has_many :documents, dependent: :destroy
  has_many :evaluation_jobs, dependent: :destroy
  has_many :audit_logs, dependent: :nullify

  before_save :downcase_email

  def self.authenticate(email, password)
    user = find_by(email: email.downcase)
    return nil unless user
    user.valid_password?(password) ? user : nil
  end

  def valid_password?(password)
    return false if password.blank? || password_hash.blank?

    begin
      BCrypt::Password.new(password_hash) == password
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def password=(value)
    @password = value
    if value.present?
      self.password_hash = BCrypt::Password.create(value)
    end
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def password_required?
    password_hash.blank?
  end
end
