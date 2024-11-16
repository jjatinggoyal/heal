# Heal

Heal is a command-line interface for managing Git workflows and configurations.

## Installation

To install the Heal CLI, follow these steps:

1. **Add the gem to your Gemfile**:
   ```ruby
   gem 'heal'
   ```

2. **Install the gem**:
   Run the following command in your terminal:
   ```bash
   bundle install
   ```

   If you are not using Bundler, you can install the gem directly:
   ```bash
   gem install heal
   ```

3. **Verify the installation**:
   After installation, you can verify that the Heal CLI is working by running:
   ```bash
   heal help
   ```

## Available Commands

### Configuration

- **`config`**: 
  - **Description**: Displays the current configuration settings.
  - **Usage**: 
    ```bash
    heal config
    ```

### Git Commands

- **`git delivery ISSUE_ID`**: 
  - **Description**: Delivers an issue to the test environment by checking out the relevant branches and cherry-picking commits associated with the specified issue ID.
  - **Usage**: 
    ```bash
    heal git delivery <ISSUE_ID>
    ```

- **`git release EPIC_ID`**: 
  - **Description**: Releases an EPIC to a production-ready branch. (Currently not implemented.)
  - **Usage**: 
    ```bash
    heal git release <EPIC_ID>
    ```

## Configuration File

The Heal CLI uses a configuration file to manage settings. By default, the configuration file is located at `~/.heal/config.yml`. You can specify a different path using the `-c` option.

### Configuration Structure

The configuration file should include the following sections:

- **git**: Contains Git-related settings.
  - **repos**: An array of repository paths that the CLI will manage.
  - **directories**: An array of directories to search for Git repositories.
  - **branch**: Contains branch settings.
    - **prefix**: The prefix for branch names.
    - **targets**: Specifies target branches for delivery and development.

### Example Configuration

```yaml
git:
  repos:
    - /path/to/repo1
    - /path/to/repo2
  directories:
    - ~/projects
  branch:
    prefix: "feature"
    targets:
      test: "test-branch"
      development: "dev-branch"
```

## Usage

To use the Heal CLI, simply run the command followed by the desired subcommand. For example:

```bash
heal git delivery JIRA-123
```

This command will initiate the delivery process for the issue with ID JIRA-123.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/heal/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jjatinggoyal/heal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jjatinggoyal/heal/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Heal project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/jjatinggoyal/heal/blob/master/CODE_OF_CONDUCT.md).
