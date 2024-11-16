require "thor"
require "yaml"

module Heal::Cli
  class Base < Thor

    class_option :config_file, aliases: "-c", default: File.expand_path("~/.heal/config.yml"), desc: "Path to config file"

    def initialize(*args)
      super(*args)
      load_config
    end

    private

    def load_config
        unless File.exist?(options[:config_file])
            template_path = File.expand_path("lib/heal/cli/templates/config.yml")
            FileUtils.mkdir_p(File.dirname(options[:config_file]))
            FileUtils.cp(template_path, options[:config_file])
        end
        @config = YAML.load_file(options[:config_file])

        enrich_config
    end

    def enrich_config
      enrich_git_config
    end

    def enrich_git_config
      if @config["git"] && @config["git"]["directories"].is_a?(Array)
          @config["git"]["repos"] ||= []

          @config["git"]["directories"].each do |dir|
              expanded_dir = File.expand_path(dir)

              if Dir.exist?(expanded_dir)
                  Dir.glob("#{expanded_dir}/*/.git").each do |git_dir|
                      repo_path = File.dirname(git_dir)
                      @config["git"]["repos"] << repo_path unless @config["git"]["repos"].include?(repo_path)
                  end
              end
          end
      end
    end

  end
end
