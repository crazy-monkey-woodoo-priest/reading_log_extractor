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
end
