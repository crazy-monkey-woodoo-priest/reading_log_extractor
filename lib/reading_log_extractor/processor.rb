module ReadingLogExtractor
  class Processor
    class Commit
      attr_reader :sha, :message, :author, :date

      def initialize(sha:, message:, author:, date:)
        @sha = sha
        @message = message
        @author = author
        @date = date
      end
    end

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

    def latest_commits(last_sha)
      mutex.synchronize do
        fetch_commits(gh_facade.commits(username, reponame), last_sha)
      end
    end

    private
      attr_reader :mutex

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

        def list_has_reponame?(list)
          list.map(&:name).include?(reponame)
        end

      def fetch_commits(commits, sha, collection = [])
        limit_reached = false

        commits
          .map { |g| init_commit(g) }
          .each do |commit|
            unless limit_reached
              case commit.sha
              when sha
                limit_reached = true
              else
                collection << commit
              end
            end
          end

        if !limit_reached && !(next_page = commits.next_page).nil?
          fetch_commits(next_page, sha, collection)
        end

        collection
      end

        def init_commit(gh_commit)
          Commit.new(sha: gh_commit.sha,
            message: gh_commit.commit.message,
            author:  gh_commit.author.login,
            date:    gh_commit.commit.author.date )
        end
  end
end
