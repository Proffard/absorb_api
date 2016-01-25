module AbsorbApi
  class Base
    include Orm

    def initialize(attributes = [], &block)
      attributes.each do |k,v|
        instance_variable_set("@#{k.to_s.underscore}", v) unless v.nil?
      end
      yield self if block_given?
    end
  end
end
