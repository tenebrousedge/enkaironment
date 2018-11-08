# frozen_string_literal: true

require 'i18n'

I18n.load_path << Dir[File.expand_path('config/locales') + '/*.yml']

# Provides a complete Kai-approved development environment.
# Kais sold separately.
module Enkaironment
  require 'enkaironment/version'
  require 'enkaironment/cli'
end
