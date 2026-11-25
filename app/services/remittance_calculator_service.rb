# frozen_string_literal: true

# RemittanceCalculatorService
# Handles financial conversions, exchange rate applications, and multi-tier commission splits.
class RemittanceCalculatorService
  Result = Struct.new(
    :source_cop,
    :exchange_rate,
    :target_ves,
    :commerce_commission,
    :distributor_commission,
    :wholesaler_commission,
    :platform_net,
    :total_commissions,
    keyword_init: true
  )

  # Calculates destination VES and commission allocation across the 4-tier hierarchy.
  # @param cop_amount [Numeric] Amount in Colombian Pesos (COP)
  # @param exchange_rate [Numeric] Exchange rate factor (COP per VES or conversion divisor)
  # @param commerce_rate [Float] Commission fraction for retail commerce (e.g. 0.02 = 2%)
  # @param distributor_rate [Float] Commission fraction for regional distributor (e.g. 0.01 = 1%)
  # @param wholesaler_rate [Float] Commission fraction for regional wholesaler (e.g. 0.005 = 0.5%)
  # @param platform_rate [Float] Commission fraction for platform operator (e.g. 0.015 = 1.5%)
  # @return [Result]
  def self.calculate(cop_amount:, exchange_rate:, commerce_rate: 0.02, distributor_rate: 0.01, wholesaler_rate: 0.005, platform_rate: 0.015)
    raise ArgumentError, "Amount must be positive" if cop_amount.to_f <= 0
    raise ArgumentError, "Exchange rate must be positive" if exchange_rate.to_f <= 0

    # In ColVen, target_value = value / exchange_rate
    target_ves = (cop_amount.to_f / exchange_rate.to_f).round(2)

    commerce_fee = (cop_amount.to_f * commerce_rate.to_f).round(2)
    distributor_fee = (cop_amount.to_f * distributor_rate.to_f).round(2)
    wholesaler_fee = (cop_amount.to_f * wholesaler_rate.to_f).round(2)
    platform_fee = (cop_amount.to_f * platform_rate.to_f).round(2)

    total_fees = (commerce_fee + distributor_fee + wholesaler_fee + platform_fee).round(2)

    Result.new(
      source_cop: cop_amount.to_f,
      exchange_rate: exchange_rate.to_f,
      target_ves: target_ves,
      commerce_commission: commerce_fee,
      distributor_commission: distributor_fee,
      wholesaler_commission: wholesaler_fee,
      platform_net: platform_fee,
      total_commissions: total_fees
    )
  end
end
