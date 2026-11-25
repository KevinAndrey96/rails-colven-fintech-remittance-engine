# frozen_string_literal: true

# ComplianceAuditService
# Enforces Anti-Money Laundering (AML) thresholds, document validation, and transactional risk scoring.
class ComplianceAuditService
  MAX_SINGLE_TRANSACTION_COP = 5_000_000
  MAX_DAILY_VELOCITY_ORDERS = 5

  AuditResult = Struct.new(
    :approved,
    :risk_level,
    :flags,
    :reasons,
    keyword_init: true
  )

  # Evaluates a prospective remittance against AML/KYC policies.
  # @param cop_amount [Numeric] Amount in COP
  # @param recipient_document [String] Identification (V/E/J/G + digits)
  # @param daily_orders_count [Integer] Number of orders made by client today
  # @return [AuditResult]
  def self.evaluate(cop_amount:, recipient_document:, daily_orders_count: 0)
    flags = []
    reasons = []

    # 1. Amount Threshold Check
    if cop_amount.to_f > MAX_SINGLE_TRANSACTION_COP
      flags << "AMOUNT_EXCEEDS_THRESHOLD"
      reasons << "Single transaction exceeds regulatory limit of 5,000,000 COP without enhanced KYC"
    end

    # 2. Document Format Validation
    doc = recipient_document.to_s.strip.upcase
    unless doc =~ /\A[VEJG]-?\d{6,9}\z/
      flags << "INVALID_DOCUMENT_FORMAT"
      reasons << "Document must begin with V, E, J, or G followed by 6 to 9 digits"
    end

    # 3. Transaction Velocity Check
    if daily_orders_count.to_i >= MAX_DAILY_VELOCITY_ORDERS
      flags << "HIGH_VELOCITY_FLAG"
      reasons << "Daily transaction velocity threshold reached (max 5 orders per 24 hours)"
    end

    risk_level = if flags.empty?
                   "LOW"
                 elsif flags.include?("AMOUNT_EXCEEDS_THRESHOLD")
                   "HIGH"
                 else
                   "MEDIUM"
                 end

    AuditResult.new(
      approved: flags.empty?,
      risk_level: risk_level,
      flags: flags,
      reasons: reasons
    )
  end
end
