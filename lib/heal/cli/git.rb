class Heal::Cli::Git < Heal::Cli::Base

  desc "cherry-pick-pr COMMIT_MESSAGE_IDENTIFIER REPO SOURCE_BRANCH TARGET_BRANCH THROWAWAY_BRANCH",
       "Cherry Pick a PR based on a commit message identifier (like jira key), source repository, source branch, target branch and a throwaway branch used for creating PR to target branch"
  def cherry_pick_pr(commit_message_identifier, repo, source_branch, target_branch, throwaway_branch)
    prepare repo do
      checkout_and_pull source_branch
      commits = find_commits(commit_message_identifier)
      checkout_and_pull target_branch
      checkout_new_branch throwaway_branch

      cherry_pick_commits(commits)

      git :push, :origin, throwaway_branch
      invoke "heal:cli:git:create-pr", [repo_name, throwaway_branch, target_branch]
    end
  end

  desc "find-commits COMMIT_MESSAGE_IDENTIFIER", "Find commit ids based on an identifier in commit message"
  def find_commits(commit_message_identifier)
    p `#{git :log, :"--oneline", :"--grep", commit_message_identifier, execute: false}`.lines.map { |line| line.split.first }.reverse
  end


  # Opens a link to create a PR from +source_branch+ to +target_branch+ in +repo_name+
  #
  # @param repository_name [String] name of the repository to create the PR in
  # @param source_branch [String] name of the branch to create the PR from
  # @param target_branch [String] name of the branch to create the PR to
  desc "create-pr REPO_NAME SOURCE_BRANCH TO_BRANCH", "Create a PR from a source to a target branch"
  def create_pr(repository_name, source_branch, target_branch)
    `open #{format(@config["git"]["pr_link"], repository_name, source_branch, target_branch)}`
  end

  private

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

  def checkout_new_branch(throwaway_branch)
    branch_already_present = (git :"rev-parse", :"--verify", throwaway_branch) || (git :"rev-parse", :"--verify", "origin/#{throwaway_branch}")
    if branch_already_present
      git :checkout, throwaway_branch
    else
      git :checkout, :"-b", throwaway_branch
    end
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

  def repo_name
    `#{git :remote, :"get-url", :origin, execute: false}`.match(/.*\/(.*?)\.git/)[1]
  end

  def git(*args, execute: true)
    command = [ :git, *([ "-C", @path ] if @path), *args.compact ].join(" ")
    execute ? system(command) : command
  end

end