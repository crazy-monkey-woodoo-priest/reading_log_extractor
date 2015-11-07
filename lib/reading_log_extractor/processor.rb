module ReadingLogExtractor
  class Processor
    attr_reader :username, :reponame, :gh_facade

    def initialize(username:, gh_facade:)
      @gh_facade = gh_facade
      @username = username
      @reponame = ReadingLogExtractor.config.reponame
      @mutex = Mutex.new
    end

    def repo_exist?
      mutex.synchronize do
        find_repo(gh_facade.repo_list(username))
      end
    end

    private
      attr_reader :mutex

      def list_has_reponame?(list)
        list.map(&:name).include?(reponame)
      end

      def find_repo(list)
        case list
        when ->(ary) { ary.empty? }
          false
        when ->(ary) { list_has_reponame?(list) }
          repo = list.lazy.select { |e| e.name == reponame }.first
          repo.fork # true if it's a forked project
                    # in future gem will ensure weather the for is for
                    # of had-read/reading-log
        else
          find_repo(list.next_page)
        end
      end
  end
end
