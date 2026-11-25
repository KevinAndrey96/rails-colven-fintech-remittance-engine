# frozen_string_literal: true

# VenezuelanBankDirectoryService
# Validates Venezuelan 20-digit standard bank accounts and resolves SUDEBAN routing codes.
class VenezuelanBankDirectoryService
  BANK_DIRECTORY = {
    "0102" => "Banco de Venezuela",
    "0104" => "Venezolano de Credito",
    "0105" => "Banco Mercantil",
    "0108" => "BBVA Banco Provincial",
    "0114" => "Bancaribe",
    "0115" => "Banco Exterior",
    "0116" => "Banco Occidental de Descuento (BOD)",
    "0128" => "Banco Caroni",
    "0134" => "Banesco Banco Universal",
    "0137" => "Banco Sofitasa",
    "0138" => "Banco Plaza",
    "0151" => "BFC Banco Fondo Comun",
    "0156" => "100% Banco",
    "0157" => "DelSur Banco Universal",
    "0163" => "Banco del Tesoro",
    "0166" => "Banco Agricola de Venezuela",
    "0168" => "Bancrecer",
    "0169" => "Mi Banco",
    "0171" => "Banco Activo",
    "0172" => "Bancamiga Banco Universal",
    "0174" => "Banplus Banco Universal",
    "0175" => "Banco Bicentenario",
    "0177" => "Banco de la Fuerza Armada Nacional Bolivariana (BANFANB)",
    "0191" => "Banco Nacional de Credito (BNC)"
  }.freeze

  # Validates whether an account string has exactly 20 digits and starts with a known SUDEBAN bank code.
  # @param account [String]
  # @return [Boolean]
  def self.valid_account?(account)
    cleaned = account.to_s.strip
    return false unless cleaned =~ /\A\d{20}\z/

    bank_code = cleaned[0..3]
    BANK_DIRECTORY.key?(bank_code)
  end

  # Resolves the institution name from a 20-digit bank account or 4-digit code.
  # @param account_or_code [String]
  # @return [String, nil]
  def self.detect_bank(account_or_code)
    cleaned = account_or_code.to_s.strip
    code = cleaned.length >= 4 ? cleaned[0..3] : cleaned
    BANK_DIRECTORY[code]
  end

  # Extracts the account components: bank code (4), branch (4), check digits (2), account number (10).
  # @param account [String]
  # @return [Hash, nil]
  def self.decompose_account(account)
    return nil unless valid_account?(account)

    cleaned = account.to_s.strip
    {
      bank_code: cleaned[0..3],
      bank_name: BANK_DIRECTORY[cleaned[0..3]],
      branch_code: cleaned[4..7],
      check_digits: cleaned[8..9],
      account_number: cleaned[10..19]
    }
  end
end
