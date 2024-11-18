class Heal::Cli::Main < Heal::Cli::Base

  desc "config", "Show config"
  def config
    puts @config.to_yaml
  end

  desc "delivery", "Deliver an issue to test environment"
  def delivery
    issue_id = PROMPT.ask("Please enter the Issue key...\n", required: true)

    source_branch = development_branch(issue_id)
    
    ask_repo_choices.each do |repo|
      invoke "heal:cli:git:cherry-pick-pr", [issue_id, repo, source_branch, delivery_branch, issue_branch(issue_id)]
    end
  end

  desc "release", "Release a Feature to a production ready branch"
  def release
    feature_id = PROMPT.ask("Enter the Feature key...\n", required: true)
    feature_issues = PROMPT.ask("Enter all issues under the EPIC: JIRA-1,JIRA-2,...\n", required: true, convert: :array)
    
    ask_repo_choices.each do |repo|
      feature_issues.each do |issue_id|
        invoke "heal:cli:git:cherry-pick-pr", [issue_id, repo, issue_branch(issue_id), release_branch, feature_branch(feature_id)]
      end
    end
  end

  desc "git", "Manage Git workflows"
  subcommand "git", Heal::Cli::Git

  private

  def ask_repo_choices
    choices = @config["git"]["repos"].map { |repo| { File.basename(repo) => repo } }
    PROMPT.multi_select("Choose repositories:", choices, filter: true)
  end

  def development_branch(issue_id)
    @config["git"]["branch"]["prefix"]["test"] + "/" + @config["git"]["branch"]["targets"]["development"] + "/" + issue_id
  end

  def delivery_branch
    @config["git"]["branch"]["targets"]["test"]
  end

  def release_branch
    @config["git"]["branch"]["targets"]["release"]
  end

  def issue_branch(issue_id)
    @config["git"]["branch"]["prefix"]["test"] + "/" + delivery_branch + "/" + issue_id
  end

  def feature_branch(feature_id)
    @config["git"]["branch"]["prefix"]["release"] + "/" + feature_id
  end
  
end