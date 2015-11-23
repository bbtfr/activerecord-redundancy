require 'redundancy/update_column'
require 'redundancy/update_prev_column'
require 'redundancy/update_method'
require 'redundancy/update_prev_method'

module Redundancy

  module Utils

    def self.cache_column klass, association, attribute, options
      local_klass = klass

      reflection = _reflection local_klass, association
      raise ArgumentError, "BelongsTo or HasOne reflection required" unless
        [:has_one, :belongs_to].include? reflection.macro

      foreign_key = reflection.foreign_key
      remote_klass = reflection.klass

      inverse_association = _inverse_association local_klass, remote_klass, options

      cache_column = options[:cache_column] || :"#{association}_#{attribute}"

      case reflection.macro
      when :belongs_to
        local_klass.redundacies << UpdateColumn.new(
          source: { association: association, attribute: attribute },
          dist: { association: nil, attribute: cache_column },
          change_if: foreign_key, klass: local_klass
        )

      when :has_one
        remote_klass.redundacies << UpdateColumn.new(
          source: { association: nil, attribute: attribute, nil_unless: foreign_key },
          dist: { association: inverse_association, attribute: cache_column },
          change_if: foreign_key, klass: remote_klass
        )

        remote_klass.redundacies << UpdatePrevColumn.new(
          source: options[:default],
          dist: { klass: local_klass, prev_id: foreign_key, attribute: cache_column },
          change_if: foreign_key, klass: remote_klass
        )

      end

      remote_klass.redundacies << UpdateColumn.new(
        source: { association: nil, attribute: attribute },
        dist: { association: inverse_association, attribute: cache_column },
        change_if: attribute, klass: remote_klass, update: true
      )
    end

    def self.cache_method klass, association, attribute, options
      local_klass = klass

      reflection = _reflection local_klass, association
      raise ArgumentError, "BelongsTo reflection required" unless
        [:belongs_to].include? reflection.macro

      foreign_key = reflection.foreign_key
      remote_klass = reflection.klass

      inverse_association = _inverse_association local_klass, remote_klass, options

      cache_method = options[:cache_method] || :"raw_#{attribute}"

      local_klass.redundacies << UpdateMethod.new(
        source: { attribute: cache_method },
        dist: { association: association, attribute: attribute },
        change_if: options[:change_if], klass: local_klass
      )

      local_klass.redundacies << UpdatePrevMethod.new(
        source: { attribute: cache_method },
        dist: { klass: remote_klass, prev_id: foreign_key, attribute: attribute },
        change_if: foreign_key, klass: local_klass
      )

    end

    def self._reflection klass, association
      reflection = klass.reflect_on_association(association)
      raise ArgumentError, "Unknown association :#{association}" unless reflection
      reflection
    end

    def self._inverse_association klass, reflection_klass, options
      model_name = klass.model_name
      inverse_associations = options[:inverse_of]
      inverse_associations ||= [model_name.plural, model_name.singular].map(&:to_sym)

      inverse_association = Array.wrap(inverse_associations).find do |inverse_association|
        reflection_klass.reflect_on_association(inverse_association)
      end

      raise ArgumentError, "Could not find the inverse association for #{association} (#{inverse_associations.inspect} in #{reflection_klass})" unless inverse_association
      inverse_association
    end


  end

end
