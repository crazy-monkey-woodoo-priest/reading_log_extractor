require_relative 'dummy_repo_list_facade/list'

class DummyRepoListFacade
  Repo = Struct.new(:name, :fork)

  attr_reader :usecase

  def initialize(usecase:)
    @usecase = usecase
  end

  def repo_list(list)
    List.new(*paginated_list)
  end

  private
    def paginated_list
      case usecase
      when 'user-with-valid-repo'
        [
          [DummyRepoListFacade::Repo.new('dummy 1', true), DummyRepoListFacade::Repo.new('dummy 2', true)],
          [DummyRepoListFacade::Repo.new('reading-log', true)]
        ]
      when 'user-with-valid-irelevant-repo'
        [
          [DummyRepoListFacade::Repo.new('dummy 1',true), DummyRepoListFacade::Repo.new('reading-log', false)],
        ]
      when 'user-without-repo'
        [
          [DummyRepoListFacade::Repo.new('dummy 1', false), DummyRepoListFacade::Repo.new('dummy 2', true)],
          [DummyRepoListFacade::Repo.new('dummy 3', true)],
          []
        ]
      else
        raise 'unknown usecase'
      end
    end
end
