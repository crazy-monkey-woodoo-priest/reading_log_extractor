class DummyRepoListFacade
  class List < SimpleDelegator
    attr_reader :pages

    def initialize(*pages)
      @pages = pages
      super(current_page)
    end

    def next_page
      pages.shift
      List.new(*pages)
    end

    private
      def current_page
        pages.first
      end
  end
end
