# Enkaironment

This is a tool to set up a coding environment. Specifically, it sets up things the way I like them. Right now, it's only compatible with Ubuntu 18.04, because that's all I need. The software is mostly functional, but far from optimal, and probably should not be used in its present state.

The Enkaironment tool should

  * Create a system user
  * Add that user to the sudo group
  * Allow that user to execute various sudo commands without a password:
      - find
      - chown
      - nano
      - apt
      - apt-get
      - aptitude

It should then install:

  * git
  * curl
  * zsh
  * [prezto](https://github.com/sorin-ionescu/prezto)
  * docker
  * docker-compose
  * ag
  * nvim
  * [SpaceVim](https://github.com/SpaceVim/SpaceVim)
  * rbenv
  * a recent Ruby (2.5.1 currently)

Finally, it creates a new ssh keypair for the newly created user.

## Installation

[Download the executable](https://github.com/tenebrousedge/enkaironment/releases/download/v0.1.0/enkaironment) to any directory.

## Usage

To install everything, use the "setup" command. Most commands require a username as an argument.

```shell
./enkaironment setup kai
```

This will prompt for a password almost immediately, and some minutes later it will ask for you to hit enter. Finally, you will be given the option to enter a passphrase for a new ssh key. The whole thing takes perhaps ten minutes, so it's not super quick.

## Bugs

There are several important bugs known at the time of this writing. Check the Issues page before proceeding. Report any others that you find. 

## Development

Right now, the way to develop this would be to clone the repo, then run `bundle install` to install dependencies. One can then use `rubyc` to compile a binary. The Dockerfile can also be used for compilation and testing.
There are a few automated tests, but this code mostly consists of "side effects". In point of fact, it's mostly shell commands with a small Ruby wrapper.

>  *Simplicio*: So why not write a Bash script?
>  *Kai*: Bash is the wrong language for most nontrivial applications.
>  *Simplicio*: You're sure that excludes this usage?
>  *Kai*: Some things would be easier, but I really don't like working with Bash.
>  *Simplicio*: Fair enough. But does that make Ruby the right solution?
>  *Kai*: Actually no, this should be translated into Crystal, but I wanted to
>  start with something I was familiar with.
>  *Simplicio*: Wait, so you're talking about rewriting this? Already?
>  *Kai*: Probably every project should be thrown away at about 90% completion.
>  If you don't want to, you didn't learn anything while doing it. But in
>  this case, Ruby is the wrong tool.
>  *Simplicio*: So what does that mean for any poor fools who might want to work
>  with this code?
>  *Kai*: This is a dead end in some senses. Ruby code seems to be pretty
>  directly translatable into Crystal, but it's probably best to just report
>  bugs as you find them, and wait for the next version.
>  *Simplicio*: You know, this kinda makes sense in context, but I think you
>  might deserve this "Simplicio" sobriquet a bit more.
>  *Kai*: Ouch. Well, if coding isn't a lesson in humility, it probably will be
>  soon enough. Either way, this will be better in the future.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tenebrousedge/enkaironment. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

This code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Enkaironment project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tenebrousedge/enkaironment/blob/master/CODE_OF_CONDUCT.md).
