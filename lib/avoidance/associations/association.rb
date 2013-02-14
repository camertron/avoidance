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
        targets.send(method, *args, &block)
        # targets.each do |target|
        #   target.send(method, *args, &block)
        # end
      end

      def respond_to?(method, include_private = false)
        super || targets.respond_to?(method, include_private)
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

      def class
        association.klass
      end

    end

  end
end