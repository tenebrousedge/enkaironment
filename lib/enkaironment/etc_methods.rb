
require 'etc'
module Enkaironment
 module EtcMethods

    # test if system user exists
    # @param username [String|Integer] the UID or login name of a user
    # @return [Boolean]
    def user_exists?(username)
      # @see https://github.com/rubocop-hq/rubocop/issues/3344
      # rubocop:disable Style/DoubleNegation
      !!Etc.send((username.is_a?(Numeric) ? :getpwuid : :getpwnam), username)
      # rubocop:enable Style/DoubleNegation
    rescue ArgumentError
      false
    end
  end
 end
