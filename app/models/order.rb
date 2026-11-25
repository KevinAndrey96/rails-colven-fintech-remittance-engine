# frozen_string_literal: true

class Order < ActiveRecord::Base
  STATUS_PENDING = "Espera"
  STATUS_COMPLETED = "Exitoso"
  STATUS_CANCELLED = "Cancelado"

  belongs_to :client

  mount_uploader :voucher, ImageUploader if respond_to?(:mount_uploader)

  scope :desc, -> { order('id DESC') }
  scope :pending, -> { where(status: STATUS_PENDING) }
  scope :completed, -> { where(status: STATUS_COMPLETED) }
  scope :cancelled, -> { where(status: STATUS_CANCELLED) }

  validates :account, length: { is: 20 }, format: { with: /\A\d{20}\z/, message: "must contain exactly 20 digits" }
  validates :value, numericality: { greater_than: 0 }

  before_validation :auto_detect_bank

  def pending?
    status == STATUS_PENDING
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def cancelled?
    status == STATUS_CANCELLED
  end

  def mark_as_completed!(voucher_url)
    update!(voucher: voucher_url, status: STATUS_COMPLETED)
  end

  def cancel!(reason = "Cancelado por el usuario o comercio")
    return false unless pending?

    update!(status: STATUS_CANCELLED, commentary: reason)
  end

  private

  def auto_detect_bank
    return if account.blank? || account.to_s.length < 4

    detected = VenezuelanBankDirectoryService.detect_bank(account)
    self.bank = detected if detected.present?
  end
end
