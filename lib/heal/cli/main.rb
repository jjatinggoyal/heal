class Heal::Cli::Main < Heal::Cli::Base

  desc "config", "Show config"
  def config
    puts @config.to_yaml
  end

  desc "git", "Manage Git workflows"
  subcommand "git", Heal::Cli::Git

end