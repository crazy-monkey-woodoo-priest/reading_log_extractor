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
        when /^[+]\*/
          additions << parse_line(line)
        when /^[-]\*/
          removals << parse_line(line)
        else
        end
      end
    end
  end

  private
    def parse_line(line)
      message = (msg = line.match(/\s+#(.*)$/)) ? msg[1].strip : nil
      url = URI.extract(line).first
      { url: url, message: message }
    end
end
