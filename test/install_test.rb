# frozen_string_literal: true

require 'test_helper'

describe Enkaironment::Install, 'It installs things' do
  let(:cli) { Enkaironment::Install.new }
  it 'installs prezto' do
    username = 'enk_test'
    userdir = "/home/#{username}"
    cli.expects(:user_exists?).with(username).returns(true)
    Etc.expects(:getpwnam).with(username).returns(stub('userentry', dir: userdir, uid: 9000, gid: 9000))
    Git.expects(:clone).with('https://github.com/sorin-ionescu/prezto.git', '.prezto', path: userdir)
    cli.expects(:symlink_prezto).with(userdir, userdir + '/.zprezto')
    File.expects(:chown)
    cli.prezto(username)
  end
end
