require 'redundancy/utils'

module Redundancy
  extend ActiveSupport::Concern

  included do
    before_save :update_redundacies_before_save
    after_save :update_redundacies_after_save
  end

  private

  def update_redundacies_before_save
    self.class.redundacies.each do |redundancy|
      redundancy.before_save(self)
    end
  end

  def update_redundacies_after_save
    self.class.redundacies.each do |redundancy|
      redundancy.after_save(self)
    end
  end

  def update_redundacies
    self.class.redundacies.each do |redundancy|
      redundancy.before_save(self)
      redundancy.after_save(self)
    end
  end

  module ClassMethods
    def cache_column association, attribute, options = {}
      options.assert_valid_keys(:cache_column, :inverse_of)
      Utils.cache_column self, association, attribute, options
    end

    def cache_method association, attribute, options = {}
      options.assert_valid_keys(:cache_column, :inverse_of)
      Utils.cache_method self, association, attribute, options
    end

    def redundacies
      @redundacies ||= []
    end

  end

end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Redundancy)
end
