require 'spec_helper'
require Tests.support('dummy_repo_list_facade')

RSpec.describe ReadingLogExtractor::Processor do
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

RSpec.describe ReadingLogExtractor::Processor, integration: true, vcr: { cassette_name: "github-repo-list" } do
  subject { described_class.new(username: username, gh_facade: gh_facade) }

  let(:gh_connection) { Github }
  let(:gh_facade) { ReadingLogExtractor::GithubFacade.new(gh_connection: gh_connection) }

  describe '#repo_exist?' do
    context 'Given user with valid reading-log repo' do

      let(:username) { 'equivalent' }

      it 'should return true' do
        expect(subject.repo_exist?).to be true
      end
    end
  end
end
