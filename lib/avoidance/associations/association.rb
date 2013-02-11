# encoding: UTF-8

module Avoidance

  module Associations

    class Association
      attr_reader :association, :parent, :touched

      def initialize(association, parent)
        @association = association
        @parent = parent
        @touched = false
      end

      def method_missing(method, *args, &block)
        targets.each do |target|
          target.send(method, *args, &block)
        end
      end

      def wrap(target)
        if target.is_a?(Avoidance::Model) || target.nil?
          target
        else
          Avoidance::Model.class_for(target.class).new(target)
        end
      end

      def primary_key_from(target)
        target.send(association.association_primary_key)
      end

    end

end