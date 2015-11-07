require 'spec_helper'
require 'github_api'

require Tests.support('dummy_repo_list_facade')

class GithubFacade
  attr_reader :gh_connection

  def initialize(gh_connection:)
    @gh_connection = gh_connection
  end

  def repo_list(username)
    gh_connection.repos.list user: username
  end
end

class GithubProcessor
  attr_reader :username, :reponame, :gh_facade

  def initialize(username:, gh_facade:)
    @gh_facade = gh_facade
    @username = username
    @reponame = 'reading-log'
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
        true
      else
        find_repo(list.next_page)
      end
    end
end



RSpec.describe GithubProcessor, focus: true do
  subject { described_class.new(username: 'not-important', gh_facade: gh_facade) }

  let(:gh_facade) { DummyRepoListFacade.new(usecase: usecase) }

  describe '#repo_exist?' do
    context 'Given user with valid reading-log repo' do
      let(:usecase) { 'user-with-valid-repo' }

      it 'should return true' do
        expect(subject.repo_exist?).to be true
      end
    end

    context 'Given user without reading-log repo' do
      let(:usecase) { 'user-without-repo' }

      it 'should return true' do
        expect(subject.repo_exist?).to be false
      end
    end
  end
end

RSpec.describe GithubProcessor, integration: true, vcr: { cassette_name: "github-repo-list" } do
  subject { described_class.new(username: username, gh_facade: gh_facade) }

  let(:gh_connection) { Github }
  let(:gh_facade) { GithubFacade.new(gh_connection: gh_connection) }

  describe '#repo_exist?' do
    context 'Given user with valid reading-log repo' do

      let(:username) { 'equivalent' }

      it 'should return true' do
        expect(subject.repo_exist?).to be true
      end
    end
  end
end

