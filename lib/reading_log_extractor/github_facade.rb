module ReadingLogExtractor
  class GithubFacade
    attr_reader :gh_connection

    def initialize(gh_connection:)
      @gh_connection = gh_connection
    end

    def repo_list(username)
      gh_connection.repos.list(user: username)
    end

    def commits(username, repo)
      gh_connection
        .repos
        .commits
        .list(username, repo)
    end

    def content_between(username, reponame, sha1, sha2)
      gh_connection
        .repos
        .commits
        .compare(username, reponame, sha1, sha2)
    end
  end
end
