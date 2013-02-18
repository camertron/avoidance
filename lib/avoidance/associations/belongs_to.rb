# encoding: UTF-8

module Avoidance

  module Associations

    class BelongsToAssociation < Association
      def initialize(association, parent)
        super
        fetch_target
      end

      define_method(:'=') do |new_target|
        @touched = true
        @target = new_target
      end

      def delete
        @touched = true
        @target.deleted = true
        @target = nil
      end

      def create(attributes, &block)
        @touched = true
        @target = wrap(@association.klass.new(attributes, &block))
        @target
      end

      def targets
        [fetch_target]
      end

      def method_missing(method, *args, &block)
        @target.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @target.respond_to?(method, include_private)
      end

      def persist!(create_new = false, new_parent = nil)
        @parent = new_parent if new_parent

        if create_new
          @target.model = @target.model.dup
          @target.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
          @target.persist!(create_new, @target.model)
        else
          if @target
            @target.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
            @target.persist!
          else
            parent.send(association.name).delete if @touched
          end
        end
      end

      private

      def fetch_target
        @target ||= wrap(parent.send(association.name))
      end
    end

  end

end