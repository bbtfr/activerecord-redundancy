module Redundancy

  class UpdateMethod
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
    end

    def after_save record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
      return unless need_update?(record)

      dst = dist[:association] ? record.send(dist[:association]) : record

      src = dst && source[:attribute] && dst.send(source[:attribute])
      src = nil if source[:nil_unless] && !record.send(source[:nil_unless])

      case dst
      when ActiveRecord::Base
        return if dst.send(:read_attribute, dist[:attribute]) == src
        log "update #{dst.class}(#{dst.id})##{dist[:attribute]} with #{src.inspect}"
        log "#{change_if}: #{record.send(change_if).inspect}, #{dist[:association]||"self"}.id: #{dst.id}" if change_if
        dst.send(:update_attribute, dist[:attribute], src)
      when ActiveRecord::Relation
        log "update #{dst.class}##{dist[:attribute]} with #{src.inspect}"
        dst.send(:update_all, dist[:attribute] => src)
      end
    end

    def need_update? record
      change_if.nil? || record.send(:attribute_changed?, change_if)
    end

    def log *message
      # puts *message
    end

  end

end
