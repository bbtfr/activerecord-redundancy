module Redundancy

  class UpdateColumn
    attr_reader :options
    attr_reader :source, :dist, :klass
    attr_reader :change_if, :update

    def initialize options
      @options = options
      @source, @dist = options[:source], options[:dist]
      @klass = options[:klass]

      @change_if = options[:change_if]
      @update = options[:update] || false
    end

    def before_save record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
      return unless need_update?(record)
      return if dist[:id_was] && (id_was = record.send(:attribute_was, dist[:id_was])).nil?

      dst = dist[:association] ? record.send(dist[:association]) : record

      src = source[:association] ? record.send(source[:association]) : record
      src = src && source[:attribute] && src.send(source[:attribute])
      src = nil if source[:nil_unless] && !record.send(source[:nil_unless])

      case dst
      when ActiveRecord::Base
        return if dst.send(:read_attribute, dist[:attribute]) == src
        log "#{ update ? "update" : "write" } #{dst.class}(#{dst.id})##{dist[:attribute]} with #{src.inspect}"
        log "#{change_if}: #{record.send(change_if).inspect}, #{dist[:association]||"self"}.id: #{dst.id}"
        if update
          dst.send(:update_attribute, dist[:attribute], src)
        else
          dst.send(:write_attribute, dist[:attribute], src)
        end
      when ActiveRecord::Relation
        log "update #{dst.class}##{dist[:attribute]} with #{src.inspect}"
        dst.send(:update_all, dist[:attribute] => src)
      end
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
