require 'uri'
require 'resolv'

# TODO:
# - locale file for error messages
# - short timeout for dns resolution
# - configuration option for dns resolution
# - decide how to handle no route to host exceptions

class WebAddressValidator < ActiveModel::EachValidator

  def validate_each(record, attr, value)
    uri = URI.parse(value)
    if uri.scheme.nil?
      record.errors.add(attr, "is missing protocol (e.g. http://)")
    elsif uri.scheme != "http" && uri.scheme != "https"
      record.errors.add(attr, "contains invalid protocol, '#{uri.scheme}'")
    elsif uri.host.nil?
      record.errors.add(attr, "is missing host name (e.g. www.google.com)")
    elsif !uri.host.match(/\.[a-zA-Z]{2,}$/)
      record.errors.add(attr, "is missing top level domain name (e.g. .com)")
    else
      begin
        Resolv.getaddress(uri.host)
      rescue Resolv::ResolvError
        record.errors.add(attr, "does not seem to exist (#{uri.host} not found)")
      end
    end
  rescue URI::InvalidURIError
    record.errors.add(attr, "is invalid")
  end

end
