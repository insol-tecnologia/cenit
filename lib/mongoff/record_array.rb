module Mongoff
  class RecordArray
    include Enumerable
    include Cenit::Liquidfier

    attr_reader :model, :array, :referenced, :parent

    def initialize(model, array, referenced, parent)
      @null = !array
      array ||= []
      @parent = parent
      @model = model
      @array = array
      @referenced = referenced
      @records = []
      array.each_with_index do |item, index|
        record =
          if item.is_a?(BSON::Document)
            model.record_class.new(model, item, referenced || parent.new_record?)
          elsif item.is_a?(Mongoff::Record)
            item
          else
            begin
              model.find(item)
            rescue
              nil
            end
          end
        @records << record
        array[index] =
          if referenced
            record&.id
          else
            item
          end
      end
      @changed = false
    end

    def null?
      @null
    end

    def set_not_new_record
      @records.each do |record|
        next unless record.is_a?(Record)
        record.set_not_new_record
      end
    end

    def orm_model
      model
    end

    def changed?
      @changed
    end

    def count
      array.count
    end

    def size
      count
    end

    def empty?
      @records.empty?
    end

    def each(*args, &blk)
      @records.each { |record| yield record if record } #TODO Sanitize for broken ids
    end

    def [](*several_variants)
      @records[*several_variants]
    end

    def << item
      if item.is_a?(Record) || item.class.respond_to?(:data_type) || item.is_a?(Hash)
        if item.is_a?(BSON::Document)
          item = model.record_class.new(model, item, referenced || parent.new_record?)
        elsif item.is_a?(Hash)
          item = model.new_from_json(item)
        end
        unless @records.include?(item)
          @records << item
          if referenced
            array << item.id unless array.include?(item.id)
          else
            array << item.attributes unless array.any? { |doc| doc['_id'] == item.id }
          end
        end
        @changed = true
        @null = false
      else
        raise Exception.new("Invalid value #{item}")
      end
      item
    end

    def to_ary
      to_a
    end

    def method_missing(symbol, *args, &block)
      if criteria.respond_to?(symbol)
        criteria.send(symbol, *args, &block)
      else
        super
      end
    ensure
      @criteria = nil
    end

    def respond_to?(*args)
      super || criteria.respond_to?(args[0])
    end

    def criteria
      unless @criteria
        if referenced
          @criteria = Mongoff::Criteria.new(model).any_in(id: array)
        else
          #TODO Not referenced
        end
      end
      @criteria
    end

    private :criteria
  end
end