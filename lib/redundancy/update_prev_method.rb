require 'redundancy/update_base'

module Redundancy

  class UpdatePrevMethod < UpdateBase

    def before_save record
      raise_if_class_mismatch record
      return unless need_update? record

      get_target_from_prev_id record
      get_target_from_relation_first_record
    end

    def after_save record
      return unless need_update? record
      return unless target

      get_value_from_target record
      force_update_target record
    end

  end

end
