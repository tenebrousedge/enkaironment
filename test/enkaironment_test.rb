# frozen_string_literal: true

require 'test_helper'

describe Enkaironment::CLI, 'It handles CLI interactions' do
  before do
    @term = HighLine.new(*[0, 1].map { StringIO.new })
    @cli = Enkaironment::CLI.new
    @cli.instance_variable_set(:@hl, @term)
  end

  it 'asks for a password' do
    @term.input.<<('test_password').rewind
    name = @cli.username
    assert_equal(name, 'test_password')
  end

  it 'creates a system user' do
    @cli.expects(:ask_password).returns('p@ssw0rd')
    expected = %(adduser --disabled-password --gecos '' enk_test && echo enk_test:p@ssw0rd | chpasswd)
    @cli.expects(:system).with(expected).returns(true)
    assert(@cli.create_user('enk_test'))
  end
  # Because, hey, what good are specs if we don't follow them? Also, y'know,
  # security and all that. Who knows what people will type into things. Next
  # thing you know we'll have lengthy prose in comments.
  #
  # This test brought to you by this ServerFault answer:
  # @see https://serverfault.com/questions/73084/what-characters-should-i-use-or-not-use-in-usernames-on-linux
  # which pointed to the POSIX section on usernames:
  # @see http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_437
  # which specifies the use of a specific restricted character set found here:
  # @see http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_282
  # basically it's just the ASCII alphabet and numerals, plus . _ -
  # and the hyphen should not be used as the first character
  it 'does not accept non-POSIX usernames' do
    assert_raises Thor::MalformattedArgumentError do
      @cli.create_user('inv@lid')
    end
  end

  it 'does not create a user if one already exists' do
    # what user is guaranteed to exist? The one we're running as
    @cli.expects(:system).never
    @cli.create_user(Etc.getlogin)
  end

  it 'adds a user to the sudo group' do
    user = Etc.getlogin
    @cli.expects(:system).with("adduser #{user} sudo").returns(true)
    assert(@cli.add_user_to_sudo(user))
  end

  it 'does not add nonexistent users to sudo' do
    @cli.expects(:system).never
    @cli.add_user_to_sudo('enk_test')
  end

  it 'allows the use of various sudo commands without a password' do
    FakeFS do
      @cli.expects(:user_exists?).with('enk_test').returns(true)
      @cli.expects(:find_executable).times(7).returns('/bin/true')
      FileUtils.mkdir_p '/etc/sudoers.d'
      @cli.allow_passwordless_sudo('enk_test')
      assert(File.exist?('/etc/sudoers.d/99-passwordless-sudo'))
      lines = File.read('/etc/sudoers.d/99-passwordless-sudo').split("\n")
      assert_match(/Cmnd_Alias COMMON = ([^\0]+,)+/, lines[0])
      assert_equal('enk_test ALL = (ALL) NOPASSWD: COMMON', lines[1])
    end
  end
end
