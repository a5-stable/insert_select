module InsertSelect
  class Error < StandardError; end

  class ColumnCountMisMatchError < Error
    def initialize(message)
      super(message)
    end
  end

  class ColumnNameMisMatchError < Error
    def initialize(message)
      super(message)
    end
  end
end
