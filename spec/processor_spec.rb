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

    context 'Given user has irelevant reading-log repo' do
      let(:usecase) { 'user-with-valid-irelevant-repo' }

      it 'should return true' do
        expect(subject.repo_exist?).to be false
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

RSpec.describe ReadingLogExtractor::Processor, integration: true do
  subject(:processor) { described_class.new(username: username, gh_facade: gh_facade) }

  let(:username) { 'equivalent' }
  let(:gh_connection) { Github }
  let(:gh_facade) { ReadingLogExtractor::GithubFacade.new(gh_connection: gh_connection) }

  describe '#repo_exist?', vcr: { cassette_name: "github-repo-list" } do
    context 'Given user with valid reading-log repo' do
      it 'should return true' do
        expect(subject.repo_exist?).to be true
      end
    end
  end

  describe '#latest_commits', vcr: { cassette_name: "github-commits" } do
    subject (:latest_commits) { processor.latest_commits(sha) }

    let(:expected_shas) { JSON.parse(File.read Tests.fixtures_file('shas-list.json')) }
    let(:sha) { '27ae6a97f5783acd2e35ea7bacadbbf8419c1958' }

    it 'list of commits should match the sha list' do
      expect(subject.map(&:sha)).to match_array(expected_shas)
    end

    describe 'list item' do
      subject (:item) { latest_commits.first }

      it { expect(subject.sha).to eq 'd7812cad66d725b43c0a362f2fd318487bbb1cae' }
      it { expect(subject.message).to eq 'Update reading-log.md' }
      it { expect(subject.author).to eq 'equivalent' }
      it { expect(subject.date).to eq '2015-11-04T08:12:44Z' }
    end

    context 'there is no last sha', vcr: { cassette_name: "github-commits-fresh-clone" } do
      let(:username) { 'had-read' }
      let(:sha) { nil }
      let(:expected_shas) { JSON.parse(File.read Tests.fixtures_file('fresh-clone-sha-list.json')) }

      it 'should include all commits' do
        expect(subject.map(&:sha)).to match(expected_shas)
      end
    end
  end

  describe '#content' do
    subject { processor.content(sha1, sha2) }

    context 'commit withot file change', vcr: { cassette_name: "github-content-withotu-file-change" } do
      let(:sha1) { '419350cfa751825c9c253a3a0ff215df4a809e25' }
      let(:sha2) { 'cdd7aacc9cdd1021083dc39dc2810fc3bc9cacac' }

      it do
        expect(subject).to be nil
      end
    end

    context 'commit with file change', vcr: { cassette_name: "github-content-with-file-change" } do
      let(:sha1) { '0348b915790de426aacbcd4a1094f9a80f1a8fc3' }
      let(:sha2) { '0c3ac7d2148299252fa3ef39c5f20f8b3a95c981' }
      let(:expected_diff) { File.read(Tests.fixtures_file('diffs/file-diff-1')) }

      it 'should eq the raw diff text' do
        expect(subject).to eq expected_diff
      end
    end
  end
end
