module Redundancy

  class UpdatePrevColumn
    attr_reader :options
    attr_reader :source, :dist, :klass
    attr_reader :change_if, :update

    def initialize options
      @options = options
      @source, @dist = options[:source], options[:dist]
      @klass = options[:klass]

      @change_if = options[:change_if]
    end

    def before_save record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
      return unless need_update?(record)

      prev_id = record.send(:attribute_was, dist[:prev_id])
      return unless prev_id

      log "update #{dist[:klass]}##{dist[:attribute]} with #{source.inspect}"
      dist[:klass].where(id: prev_id).send(:update_all, dist[:attribute] => source)
    end

    def after_save record
    end

    def need_update? record
      record.send(:attribute_changed?, change_if)
    end

    def log *message
      # puts *message
    end

  end

end
