require 'forwardable'

module Beatport
  class Collection
    include Enumerable
    extend Forwardable

    def_delegators :@results, :each, :'<=>', :length, :==, :===, :[], :to_a

    attr_reader :host, :path, :query, :next_query
    attr_reader :per_page_options, :page, :per_page, :total_pages, :count
    attr_reader :facets, :applied_facets, :spellcheck
    attr_reader :date_filters, :applied_date_filters

    def initialize(klass, data)
      raise ArgumentError, "Invalid data passed to Collection.new" unless data.is_a?(Hash) && data['results'].is_a?(Array)

      data['metadata'].each do |k, v|
        instance_variable_set(:"@#{k}", v)
      end

      @results = if klass == :auto
        data['results'].map do |r|
          type = Support::Inflector.camelize(r['type'])
          item_klass = Support::Inflector.constantize("Beatport::Catalog::#{type}")
          item_klass.new(r)
        end
      else
        data['results'].map { |r| klass.new(r) }
      end
    end

    def grouped
      group_by { |i| i.type.capitalize }
    end

  end
end
