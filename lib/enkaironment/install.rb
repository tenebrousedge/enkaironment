# frozen_string_literal: true

require 'thor'
require 'git'
# commands related to package installation
module Enkaironment
  class Install < Thor
    include Thor::Actions

    desc 'apt_update', 'runs apt update (as a task, so that other tasks can invoke it)', hide: true
    # runs apt update
    # theoretically this could be an 'update sources' method, in order to
    # support multiple OSes. Other install tasks could be written such that
    # they added items to an install list, similar to how `invoke` works.
    # I don't currently have any intention of doing this.
    def apt_update
      system 'apt update'
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

      # install command
      # @param packages [Array<String>] one or more packages to install
      def install(*packages)
        invoke 'install apt_update'
        system %(DEBIAN_FRONTEND=noninteractive apt -y install #{packages.join(' ')})
      end
    end

    desc 'git', 'installs git-all'
    # installs git
    def git
      install 'git-all'
    end

    desc 'curl', 'install curl'
    # installs curl
    def curl
      install 'curl'
    end

    desc 'ruby_build_deps', 'installs build dependencies for Ruby (rbenv-build needs these)'
    # Installs ruby build dependencies
    def ruby_build_deps
      install %w[autoconf bison build-essential libssl-dev libyaml-dev
                 libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev]
    end

    desc 'docker', 'installs docker'
    def docker
      invoke 'install curl'
      install %w[apt-transport-https ca-certificates software-properties-common]
      system 'curl -fsSL https://download.docker.com/libux/ubuntu/gpg | apt-key add -'
      system 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"'
      apt_update # hard requirement
      install 'docker-ce'
    end

    desc 'docker-compose', 'installs docker-compose'
    method_option aliases: 'docker-compose'
    # Installs docker-compose
    def docker_compose
      filename = '/usr/local/bin/docker-compose'
      system format(%(curl -L \
      "https://github.com/docker/compose/releases/download/%<version>s/docker-compose-Linux-x86_64" -o %<filename>s
      ), version: '1.23.0-rc3', filename: filename) # easier to find/change when there's a label
      File.chmod(filename, 0o755)
    end

    desc 'neovim', 'installs neovim'
    # Installs neovim from official PPA
    def neovim
      system 'add-apt-repository ppa:neovim-ppa/stable'
      apt_update
      install 'neovim'
    end

    desc 'ag', 'install the silver searcher'
    # installs the ag utility
    def ag
      install 'silversearcher-ag'
    end

    class_option :username, type: :string
    desc 'zsh [USERNAME]', 'install zsh (and make it the default)'
    # installs zsh
    # @param username [String] username to set shell default for
    def zsh(username)
      install 'zsh'
      system %(chsh -s `which zsh` #{username}) if user_exists?(username)
    end

    desc 'prezto [USERNAME]', 'install prezto'
    # installs prezto
    # @param username [String] prezto will be installed to the home directory corresponding to this username
    def prezto(username)
      return unless user_exists?(username)

      user = Etc.getpwnam(username)
      preztodir = user.dir + '/.zprezto'
      Git.clone('https://github.com/sorin-ionescu/prezto.git', '.prezto', path: user.dir)
      symlink_prezto(user.dir, preztodir)
      File.chown(user.uid, user.gid, *Dir["#{user.dir}/.z*", "#{preztodir}/**"])
    end

    desc 'rbenv [USERNAME]', 'installs rbenv to a given user\'s home directory'
    # Installs rbenv to a given user's home directory
    def rbenv(username)
      return unless user_exists?(username)

      user = Etc.getpwnam(username)
      system %(sudo -u #{username} git clone https://github.com/rbenv/rbenv.git #{user.dir}/.rbenv)
      rbenv_shim = %(export PATH="$HOME/.rbenv/bin:$PATH"\neval "$(rbenv init -)")
      %w[zshrc bashrc].map { |f| "#{user.dir}/.#{f}" }.
        select(&File.method(:file?)).
        map { |filename| append_to_file(filename, rbenv_shim) }
    end

    desc 'rbenv-build [USERNAME]', 'installs rbenv-build'
    method_option aliases: 'rbenv-build'
    # installs rbenv-build
    # @todo write some sort of wrapper method for requiring the username to exist
    # @param username [String]
    def rbenv_build(username)
      return unless user_exists?(username)

      %w[git rbenv ruby_build_deps].map { |task| "install #{task}" }.
        map(&method(:invoke))
      system %(sudo -u #{username} git clone \
        https://github.com/rbenv/ruby-build.git \
        #{Etc.getpwnam(username).dir}/.rbenv/plugins/ruby-build
      )
    end

    desc 'ruby [USERNAME] [VERSION]', 'installs ruby using rbenv'
    method_option :version, type: :string, default: '2.5.1'
    # installs ruby using rb-env
    def ruby(username, version = '2.5.1')
      system "sudo -u #{username} rbenv install #{version}"
    end

    desc 'spacevim [USERNAME]', 'installs spacevim for the given user'
    # Installs spacevim for a given user
    # @param username [String]
    def spacevim(username)
      system "sudo -u #{username} " + `curl -sLf https://spacevim.org/install.sh`
    end

    desc 'ssh_keygen [USERNAME] [FILENAME]', 'generates a SSH keypair'
    method_option :filename, type: :string, default: '~/.ssh/id_rsa'
    # Generates a SSH keypair
    def ssh_keygen(username, filename = '~/.ssh/id_rsa')
      system "sudo -u #{username} ssh-keygen -f #{filename}"
    end
  end
end
