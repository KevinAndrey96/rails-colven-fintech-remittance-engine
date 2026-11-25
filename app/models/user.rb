# frozen_string_literal: true

class User < ActiveRecord::Base
  ROLE_ADMIN = "Admin"
  ROLE_TRANSFER = "Transfer"
  ROLE_WHOLESALER = "Wholesaler"
  ROLE_DISTRIBUTOR = "Distributor"
  ROLE_COMMERCE = "Commerce"

  ROLES = [ROLE_ADMIN, ROLE_TRANSFER, ROLE_WHOLESALER, ROLE_DISTRIBUTOR, ROLE_COMMERCE].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :role, inclusion: { in: ROLES }, allow_nil: true

  def admin?
    role == ROLE_ADMIN
  end

  def transfer?
    role == ROLE_TRANSFER
  end

  def wholesaler?
    role == ROLE_WHOLESALER
  end

  def distributor?
    role == ROLE_DISTRIBUTOR
  end

  def commerce?
    role == ROLE_COMMERCE
  end
end
