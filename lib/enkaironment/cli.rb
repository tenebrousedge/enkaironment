# frozen_string_literal: true

# So, Ruby has a lot of ways to include or otherwise reference methods.
# Delegation is a thing, and various variations on mixins, and even
# inheritance. This kind of module is being used for its lack of sophistication

require 'highline/import'
require 'thor'

module Enkaironment
  # commands related to package installation
  class Install < Thor
    include Thor::Actions

    desc 'git', 'installs git-all'
    # installs git
    def git
      invoke 'apt_update'
      system 'apt install -y git-all'
    end

    desc 'curl', 'install curl'
    # installs curl
    def curl
      invoke 'apt_update'
      system 'apt install -y curl'
    end

    desc 'zsh', 'install zsh (and make it the default)'
    # installs zsh
    # @param username [String] username to set shell default for
    def zsh(username = self.username)
      invoke 'apt_update'
      system 'apt install -y zsh'
      system %(chsh -s `which zsh` #{username}) if user_exists?(username)
    end

    no_commands do
      # rubocop was complaining about the complexity of the install step
      # @param userdir [String] path to user's home directory
      # @param preztodir [String] path to prezto installation
      def symlink_prezto(userdir, preztodir)
        Dir.entries("#{preztodir}/runcoms/").reject { |f| f.match?(/(^README)|(^\.{1,2}$)/i) }.
          map do |rcfile|
            File.symlink("#{preztodir}/runcoms/#{rcfile}", "#{userdir}/.#{rcfile}")
          end
      end
    end
    desc 'prezto', 'install prezto'
    # installs prezto
    # @param username [String] prezto will be installed to the home directory corresponding to this username
    def prezto(username = self.username)
      return unless user_exists?(username)

      user = Etc.getpwnam(username)
      preztodir = user.dir + '/.zprezto'
      system %(sudo -u #{username} zsh -c "git clone --recursive \
      https://github.com/sorin-ionescu/prezto.git #{preztodir}")
      symlink_prezto(user.dir, preztodir)
      File.chown(user.uid, user.gid, *Dir["#{user.dir}/.z*", "#{preztodir}/**"])
    end

    desc 'ruby build deps', 'installs build dependencies for Ruby (rbenv-build needs these)'
    # Installs ruby build dependencies
    def ruby_build_deps
      invoke 'apt_update'
      system 'apt install -y autoconf bison build-essential libssl-dev \
      libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev \
      libgdbm5 libgdbm-dev'
    end

    desc 'rbenv', 'installs rbenv to a given user\'s home directory'
    # Installs rbenv to a given user's home directory
    def rbenv(username = self.username)
      return unless user_exists?(username)

      user = Etc.getpwnam(username)
      system %(sudo -u #{username} git clone https://github.com/rbenv/rbenv.git #{user.dir}/.rbenv)
      rbenv_shim = %(export PATH="$HOME/.rbenv/bin:$PATH"\neval "$(rbenv init -)")
      %w[zshrc bashrc].map { |f| "#{user.dir}/.#{f}" }.
        select(&File.method(:file?)).
        map { |filename| append_to_file(filename, rbenv_shim) }
    end

    desc 'rbenv-build', 'installs rbenv-build'
    method_option aliases: 'rbenv-build'
    # installs rbenv-build
    # @todo write some sort of wrapper method for requiring the username to exist
    # @param username [String]
    def rbenv_build(username = self.username)
      return unless user_exists?(username)

      invoke 'install:git'
      %w[install:rbenv install:ruby_build_deps].map(&method(:invoke))
      system %(sudo -u #{username} git clone \
        https://github.com/rbenv/ruby-build.git \
        #{Etc.getpwnam(username).dir}/.rbenv/plugins/ruby-build
      )
    end

    desc 'docker', 'installs docker'
    def docker
      %w[apt_update install:curl].map(&method(:invoke))
      system 'apt install -y apt-transport-https ca-certificates software-properties-common'
      system 'curl -fsSL https://download.docker.com/libux/ubuntu/gpg | apt-key add -'
      system 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"'
      apt_update # hard requirement
      system 'apt install -y docker-ce'
    end
  end
  # class for interacting with the end-user
  # it's okay, they do not bite (usually)
  class CLI < Thor
    include Thor::Actions

    no_commands do
      def self.as_user(name)
        old_euid = Process.euid
        begin
          Process::Sys.seteuid(Process::UID.from_name(name))
          yield
        ensure
          Process::Sys.seteuid(old_euid)
        end
      end

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
      def password
        @password ||= hl.ask(I18n.t(:ask_password))
      end

      # test if system user exists
      # @param username [String|Integer] the UID or login name of a user
      # @return [Boolean]
      def user_exists?(username)
        # @see https://github.com/rubocop-hq/rubocop/issues/3344
        # rubocop:disable Style/DoubleNegation
        !!ETC.send((username.is_a? Numeric ? :getpwuid : :getpwnam), username)
        # rubocop:enable Style/DoubleNegation
      end
    end

    desc 'create_user', 'creates a new system user'
    # Creates a new system user
    # @param username [String] username to create
    # @param password [String]
    # @return [Boolean]
    def create_user(username = self.username, password = self.password)
      return if user_exists?(username)

      system %(adduser --disabled-password --gecos '')
      system %(echo #{username}:#{password} | chpasswd)
    end

    desc 'add_user_to_sudo', 'adds a user to the sudo group'
    # Adds a user to the sudo group
    # @param username [String] username to add to sudo group
    def add_user_to_sudo(username = self.username)
      system %(adduser #{username} sudo) if user_exists?(username)
    end

    desc 'allow_passwordless_sudo', 'allow a few common programs to be used as superuser without a password'
    long_desc 'this should allow one to use apt-get (and derivatives) as \
    superuser without typing a password, and ditto for mkdir, make, find, and \
    nano. The rm command is very deliberately omitted from this list.'
    # Allows certain programs to be used as superuser without a password
    # @param username [String] username to give access to
    def allow_passwordless_sudo(username = self.username)
      return unless user_exists?(username)

      allowed_commands = ['apt', 'apt-get', 'aptitude', 'mkdir', 'make', 'nano', 'find'].
                         map { |e| `which #{e}`.chomp }.
                         reject(&:blank?).
                         join(', ')
      File.open '/etc/sudoers.d/99-passwordless-sudo', 'a' do |f|
        f << <<~SUDOFILE
          CMnd_Alias COMMON = #{allowed_commands}
          #{USERNAME} ALL = NOPASSWD: COMMON
        SUDOFILE
      end
    end

    desc 'apt_update', 'runs apt update (as a task, so that other tasks can invoke it)'
    # runs apt update
    # theoretically this could be an 'update sources' method, in order to
    # support multiple OSes. Other install tasks could be written such that
    # they added items to an install list, similar to how `invoke` works.
    # I don't currently have any intention of doing this.
    def apt_update
      # hopefully this actually works
      ENV['DEBIAN_FRONTEND'] = 'noninteractive'
      system 'apt update'
    end
    desc 'install', 'installation commands'
    subcommand :install, Enkaironment::Install
  end

end
