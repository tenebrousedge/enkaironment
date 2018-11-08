# frozen_string_literal: true

# So, Ruby has a lot of ways to include or otherwise reference methods.
# Delegation is a thing, and various variations on mixins, and even
# inheritance. This kind of module is being used for its lack of sophistication

require 'highline/import'

module Enkaironment
  # class for interacting with the end-user
  # it's okay, they do not bite (usually)
  class CLI
    extend Forwardable

    def_delegators :@hl, :ask, :say

    def initialize(highline = Highline.new)
      @hl = highline
    end

    # method for obtaining the username from the command line
    # @return [String]
    def ask_username
      # ^(?!-)[\w-]+$
      # (start-of-line)(not-a-hyphen)(word-characters-plus-hyphen)(end-of-line)
      # it's probably not possible to type a multiline string
      ask(I18n.t(:ask_username)) do |q|
        q.validate = /^(?!-)[\w.-]+$/
      end
    end

    # method for obtaining the password from the command line
    # @return [String]
    def ask_password
      ask(I18n.t(:ask_password))
    end
  end
end
