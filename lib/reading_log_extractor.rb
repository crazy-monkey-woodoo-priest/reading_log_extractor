require 'github_api'
require 'ostruct'
require "reading_log_extractor/version"
require "reading_log_extractor/github_facade"
require "reading_log_extractor/processor"

module ReadingLogExtractor
  class Config
    attr_writer :reponame

    def reponame
      @reponame || 'reading-log'
    end
  end

  def self.config
    @config ||= Config.new
  end
end
