require 'spec_helper'

RSpec.describe Parser do
  subject(:parser) { described_class.new(diff) }

  context 'given diff with single addition' do
    let(:diff) { File.read(Tests.fixtures_file('diffs/file-diff-1')) }

    before do
      parser.call
    end

    it 'should inclued addition' do
      expect(subject.additions).to match_array([
        {
          url: 'http://jpospisil.com/2014/06/16/the-definitive-guide-to-arel-the-sql-manager-for-ruby.html',
          message: 'arel tricks'
        }
      ])
    end

    it 'should have empty removals' do
      expect(subject.removals).to be_empty
    end
  end

  context 'given diff with multiple actions' do
    let(:diff) { File.read(Tests.fixtures_file('diffs/multiple-action-diff')) }

    before do
      parser.call
    end

    it 'should inclued addition' do
      puts subject.additions
      expect(subject.additions).to match_array([
        {:url=>"https://vimeo.com/45140590", :message=>"Jim Weirich: Adventures in Functional Programming"},
        {:url=>"https://www.youtube.com/watch?v=7Zlp9rKHGD4", :message=>"uncle bob on function programing"},
        {:url=>"http://www.eq8.eu", :message=>nil}
      ])
    end

    it 'should have empty removals' do
      expect(subject.removals).to match_array([
        { url: "http://docs.voltframework.com/en/tutorial/a_sample_todo_app.html", message: nil }
      ])
    end
  end
end
