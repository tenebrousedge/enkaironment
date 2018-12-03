# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'enkaironment'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/filesystem'
require 'pp'
require 'fakefs/safe'
require 'mocha/minitest'
require 'fileutils'
