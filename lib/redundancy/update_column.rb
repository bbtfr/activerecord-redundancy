require 'redundancy/update_base'

module Redundancy

  class UpdateColumn < UpdateBase

    def before_save record
      raise_if_class_mismatch record
      return unless need_update? record

      get_target_from_association record
      get_value_from_association record

      update_target record
    ensure
      cleanup_context
    end

  end

end
