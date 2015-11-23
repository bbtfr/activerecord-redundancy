module Redundancy

  class UpdatePrevMethod
    attr_reader :options
    attr_reader :source, :dist, :klass
    attr_reader :change_if, :update, :dst

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

      @dst = dist[:klass].find(prev_id)
    end

    def after_save record
      return unless dst

      src = dst && source[:attribute] && dst.send(source[:attribute])
      src = nil if source[:nil_unless] && !record.send(source[:nil_unless])

      return if dst.send(:read_attribute, dist[:attribute]) == src
      log "#{ update ? "update" : "write" } #{dst.class}(#{dst.id})##{dist[:attribute]} with #{src.inspect}"
      log "#{change_if}: #{record.send(change_if).inspect}, #{dist[:association]||"self"}.id: #{dst.id}"
      dst.send(:update_attribute, dist[:attribute], src)
    end

    def need_update? record
      record.send(:attribute_changed?, change_if)
    end

    def log *message
      # puts *message
    end

  end

end
