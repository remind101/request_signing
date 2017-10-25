require "webrick/httputils"
require "request_signing/errors"
require "request_signing/signature_parameters"

module RequestSigning

  # @api private
  class ParameterParser
    def parse(signature_parameters_str)
      values = values_hash(signature_parameters_str)
      raise BadSignatureParameters, "keyId is required"     if String(values["keyId"]).empty?
      raise BadSignatureParameters, "algorithm is required" if String(values["algorithm"]).empty?
      raise BadSignatureParameters, "signature is required" if String(values["signature"]).empty?

      headers = String(values["headers"]).split(" ").map(&:downcase)
      headers = ["date"] if headers.empty?

      SignatureParameters.new(
        key_id:    values["keyId"],
        algorithm: values["algorithm"],
        headers:   headers,
        signature: values["signature"]
      )
    end

    private

    def values_hash(signature_parameters_str)
      fields = WEBrick::HTTPUtils.split_header_value(signature_parameters_str)
      fields.each_with_object({}) do |f, r|
        fname, quoted_value = f.split("=", 2).map { |t| String(t).strip }
        unless quoted_value =~ /\A".*\"\Z/
          raise BadSignatureParameters, "malformed field value"
        end
        value = WEBrick::HTTPUtils.dequote(quoted_value)
        r[fname] = value
      end
    end
  end

end
