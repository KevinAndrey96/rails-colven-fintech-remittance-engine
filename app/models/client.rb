# frozen_string_literal: true

class Client < ActiveRecord::Base
  has_many :orders, dependent: :nullify

  validates :document, presence: true
  validates :name, presence: true

  def total_remittances
    orders.count
  end

  def total_cop_sent
    orders.sum(:value)
  end
end
