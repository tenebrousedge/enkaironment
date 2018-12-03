# frozen_string_literal: true

# So, Ruby has a lot of ways to include or otherwise reference methods.
# Delegation is a thing, and various variations on mixins, and even
# inheritance. This kind of module is being used for its lack of sophistication

require 'highline/import'
require 'etc'
require 'mkmf'
require 'thor'
require 'enkaironment/install'

module Enkaironment
  # class for interacting with the end-user
  # it's okay, they do not bite (usually)
  class CLI < Thor
    include Thor::Actions

    no_commands do
      def hl
        @hl ||= Highline.new
      end

      # method for obtaining the username from the command line
      # @return [String]
      def username
        # ^(?!-)[\w-]+$
        # (start-of-line)(not-a-hyphen)(word-characters-plus-hyphen)(end-of-line)
        # it's probably not possible to type a multiline string
        @username ||= hl.ask(I18n.t(:ask_username)) do |q|
          q.validate = /^(?!-)[\w.-]+$/
        end
      end

      # method for obtaining the password from the command line
      # @return [String]
      def ask_password
        hl.ask(I18n.t(:ask_password))
      end

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

    desc 'create_user', 'creates a new system user'
    # Creates a new system user
    # @param username [String] username to create
    # @return [Boolean]
    def create_user(username)
      return if user_exists?(username)
      raise Thor::MalformattedArgumentError unless username.match?(/^(?!-)[\w.-]+$/)

      cmd = %(adduser --disabled-password --gecos '' %<user>s && echo %<user>s:%<password>s | chpasswd)
      system format(cmd, user: username, password: ask_password)
    end

    desc 'add_user_to_sudo', 'adds a user to the sudo group'
    # Adds a user to the sudo group
    # @param username [String] username to add to sudo group
    def add_user_to_sudo(username)
      system %(adduser #{username} sudo) if user_exists?(username)
    end

    desc 'allow_passwordless_sudo', 'allow a few common programs to be used as superuser without a password'
    long_desc 'this should allow one to use apt-get (and derivatives) as \
    superuser without typing a password, and ditto for mkdir, make, find, and \
    nano. The rm command is very deliberately omitted from this list.'
    # Allows certain programs to be used as superuser without a password
    # @param username [String] username to give access to
    def allow_passwordless_sudo(username)
      return unless user_exists?(username)

      allowed_commands = ['apt', 'apt-get', 'aptitude', 'mkdir', 'make', 'nano', 'find'].
                         map(&method(:find_executable)).
                         compact.
                         join(', ')
      File.open '/etc/sudoers.d/99-passwordless-sudo', 'a' do |f|
        f << <<~SUDOFILE
          Cmnd_Alias COMMON = #{allowed_commands}
          #{username} ALL = (ALL) NOPASSWD: COMMON
        SUDOFILE
      end
    end

    desc 'setup', 'perform all setup and installation tasks'
    # Install all the things
    def setup(_username)
      ['create_user',
       'add_user_to_sudo',
       'allow_passwordless_sudo',
       *%w[git curl prezto rbenv docker docker_compose neovim spacevim ag].map { |e| "install_#{e}" },
       'ssh_keygen'].map(&method(:invoke))
    end

    desc 'install', 'installation commands'
    subcommand :install, Enkaironment::Install
  end
end
