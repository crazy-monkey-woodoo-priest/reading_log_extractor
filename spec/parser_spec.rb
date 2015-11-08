require 'spec_helper'

class Parser
  attr_reader :raw_content, :additions, :removals

  def initialize(raw_content)
    @raw_content = raw_content
    @additions = []
    @removals = []
    @mutex = Mutex.new
  end

  def call
    @mutex.synchronize do
      raw_content.each_line do |line|
        case line
        when /^\+/
          additions << parse_line(line)
        when /^\-/
          removals << parse_line(line)
        else
        end
      end
    end
  end

  private
    def parse_line(line)
      { url: URI.extract(line).first, message: line.match(/\s+#(.*)$/)[1].strip }
    end
end

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
