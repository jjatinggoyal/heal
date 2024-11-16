class Heal::Cli::Git < Heal::Cli::Base

  desc "delivery ISSUE_ID", "Deliver an issue to test environment"
  def delivery(issue_id)
    ask_repo_choices.each do |repo|
      prepare(repo) do
        checkout_and_pull development_branch(issue_id)
        commits = issue_commits issue_id
        checkout_and_pull delivery_branch
        git :checkout, :"-b", issue_branch(issue_id)

        cherry_pick_commits(commits.reverse)
        
        git :push, :origin, issue_branch(issue_id)
        create_pr from: issue_branch(issue_id), to: delivery_branch
      end
    end
  end

  desc "release EPIC_ID", "Release an EPIC to a production ready branch"
  def release(epic_id)

  end

  private

  def ask_repo_choices
    choices = @config["git"]["repos"].map { |repo| { File.basename(repo) => repo } }
    PROMPT.multi_select("Choose repositories:", choices, filter: true)
  end

  def delivery_branch
    @config["git"]["branch"]["targets"]["test"]
  end

  def development_branch(issue_id)
    @config["git"]["branch"]["prefix"] + "/" + @config["git"]["branch"]["targets"]["development"] + "/" + issue_id
  end

  def issue_branch(issue_id)
    @config["git"]["branch"]["prefix"] + "/" + delivery_branch + "/" + issue_id
  end

  def prepare(repo_path)
    @path = repo_path
    original_branch = current_branch
    stashed = stash_changes
    git :fetch
    yield
    git :checkout, original_branch
    git :stash, :pop if stashed
  end

  def checkout_and_pull(branch)
    git :checkout, branch
    git :merge, "origin/#{branch}"
  end

  def issue_commits(issue_id)
    `#{git :log, :"--oneline", :"--grep", issue_id, execute: false}`.lines.map { |line| line.split.first }
  end

  def current_branch
    `#{git :"rev-parse", :"--abbrev-ref", :HEAD, execute: false}`.strip
  end

  def stash_changes
    has_changes = !`#{git :status, :"--porcelain", execute: false}`.empty?
    if has_changes
      say "Stashing changes from current branch (#{current_branch})...", :magenta
      git :stash, :"-u"
      return true
    end
    false
  end

  def create_pr(from:, to:)
    `open #{format(@config["git"]["pr_link"], repo_name, from, to)}`
  end

  def repo_name
    `#{git :remote, :"get-url", :origin, execute: false}`.match(/.*\/(.*?)\.git/)[1]
  end

  def git(*args, execute: true)
    command = [ :git, *([ "-C", @path ] if @path), *args.compact ].join(" ")
    execute ? system(command) : command
  end

  def cherry_pick_commits(commits)
    commits.each do |commit|
      result = git :"cherry-pick", :"-x", :"--no-merges", commit
      unless result
        say "Conflict occurred while cherry-picking commit #{commit}. Please resolve the conflict and press any key to continue.", :red
        
        loop do
          # Check if there are unresolved conflicts
          if `#{git :status, execute: false}`.include?("Unmerged paths")
            PROMPT.keypress("Please resolve the conflicts and then press any key to continue...", active_color: :red)
          else
            say "Conflict resolved. Continuing with cherry-picking.", :green
            git :"cherry-pick", :"--continue"
            break # Exit the loop if conflicts are resolved
          end
        end
      end
    end
  end

end