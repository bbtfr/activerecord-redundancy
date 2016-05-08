require 'redundancy/update_column'
require 'redundancy/update_prev_column'
require 'redundancy/update_method'
require 'redundancy/update_prev_method'

module Redundancy

  module Utils

    def self.cache_column klass, association, attribute, options
      local_klass = klass

      reflection = get_reflection local_klass, association
      raise ArgumentError, "BelongsTo or HasOne reflection required" unless
        [:has_one, :belongs_to].include? reflection.macro

      foreign_key = reflection.foreign_key
      remote_klass = reflection.klass

      inverse_association = get_inverse_association local_klass, remote_klass, reflection.options

      cache_column = options[:cache_column] || :"#{association}_#{attribute}"

      case reflection.macro
      when :belongs_to
        local_klass.redundancies << UpdateColumn.new(
          source: { association: association, attribute: attribute },
          dest: { association: nil, attribute: cache_column },
          change_if: foreign_key, klass: local_klass
        )

      when :has_one
        if reflection.through_reflection

          through_reflection = reflection.through_reflection
          if through_reflection.through_reflection
            raise ArgumentError, "Multi level has_one through reflection is not support yet!"
          end

          through_foreign_key = through_reflection.foreign_key
          through_remote_klass = through_reflection.klass
          through_association = reflection.source_reflection_name
          through_inverse_association = get_inverse_association local_klass, through_remote_klass

          case through_reflection.macro
          when :belongs_to
            local_klass.redundancies << UpdateColumn.new(
              source: { association: association, attribute: attribute },
              dest: { association: nil, attribute: cache_column },
              change_if: through_foreign_key, klass: local_klass
            )

          when :has_one
            raise ArgumentError, "has_one through has_one reflection is not support yet!"
          end

          through_remote_klass.redundancies << UpdateColumn.new(
            source: { association: through_association, attribute: attribute },
            dest: { association: through_inverse_association, attribute: cache_column },
            change_if: foreign_key, klass: through_remote_klass
          )

        else
          remote_klass.redundancies << UpdateColumn.new(
            source: { association: nil, attribute: attribute, nil_unless: foreign_key },
            dest: { association: inverse_association, attribute: cache_column },
            change_if: foreign_key, klass: remote_klass
          )

          remote_klass.redundancies << UpdatePrevColumn.new(
            source: options[:default],
            dest: { klass: local_klass, prev_id: foreign_key, attribute: cache_column },
            change_if: foreign_key, klass: remote_klass
          )

        end

      end

      remote_klass.redundancies << UpdateColumn.new(
        source: { association: nil, attribute: attribute },
        dest: { association: inverse_association, attribute: cache_column },
        change_if: attribute, klass: remote_klass, update: true
      )
    end

    def self.cache_method klass, association, attribute, options = {}
      local_klass = klass

      reflection = get_reflection local_klass, association
      raise ArgumentError, "BelongsTo reflection required" unless
        [:belongs_to].include? reflection.macro

      foreign_key = reflection.foreign_key
      remote_klass = reflection.klass

      cache_method = options[:cache_method] || :"raw_#{attribute}"

      local_klass.redundancies << UpdateMethod.new(
        source: { attribute: cache_method },
        dest: { association: association, attribute: attribute },
        change_if: options[:change_if], klass: local_klass
      )

      local_klass.redundancies << UpdatePrevMethod.new(
        source: { attribute: cache_method },
        dest: { klass: remote_klass, prev_id: foreign_key, attribute: attribute },
        change_if: foreign_key, klass: local_klass
      )

    end

    private

    def self.get_reflection klass, association
      reflection = klass.reflect_on_association(association)
      raise ArgumentError, "Unknown association :#{association}" unless reflection
      reflection
    end

    def self.get_inverse_association klass, reflection_klass, options = {}
      model_name = klass.model_name
      inverse_associations = options[:inverse_of]
      inverse_associations ||= [model_name.plural, model_name.singular].map(&:to_sym)

      inverse_association = Array.wrap(inverse_associations).find do |inverse_association|
        reflection_klass.reflect_on_association(inverse_association)
      end

      raise ArgumentError, "Could not find the inverse association for #{model_name} (#{inverse_associations.inspect} in #{reflection_klass})" unless inverse_association
      inverse_association
    end

  end

end
