# frozen_string_literal: true

require 'test_helper'

describe Enkaironment::CLI, 'It handles CLI interactions' do
  before do
    @term = HighLine.new(*[0, 1].map { StringIO.new })
    @cli = Enkaironment::CLI.new(@term)
  end

  it 'asks for a username' do
    # this test should sufficiently test the normal input path
    @term.input.<<('test_username').rewind
    name = @cli.ask_username
    assert_equal(name, 'test_username')
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
    @term.input.<<("inv@lid\nvalid\n").rewind
    assert_equal('valid', @cli.ask_username)
    expected = "Please enter a POSIX-compatible username.\nYour answer isn't \
valid (must match /^(?!-)[\\w.-]+$/).\n?  "
    assert_equal(expected, @term.output.string)
  end

  it 'can be invoked from the command line' do
  end

  it 'accepts arguments from the command line' do
  end
end
