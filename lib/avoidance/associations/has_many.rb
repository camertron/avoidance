# encoding: UTF-8

module Avoidance

  module Associations

    class HasManyAssociation < Association
      include Enumerable

      def initialize(association, parent)
        super
        @targets = []
      end

      define_method(:<<) do |new_target|
        fetch_targets
        @targets << wrap(new_target)
        @targets
      end

      alias :push :<<
      alias :add :<<

      define_method(:'+=') do |new_targets|
        fetch_targets
        @targets += new_targets.map { |target| wrap(target) }
        @targets
      end

      define_method(:'=') do |new_targets|
        @touched = true
        @targets = new_targets.map { |target| wrap(target) }
      end

      def create(attributes, &block)
        fetch_targets
        target = wrap(@association.klass.new(attributes, &block))
        @targets << target
        target
      end

      def first
        fetch_targets
        @targets.first
      end

      def last
        fetch_targets
        @targets.last
      end

      def [](index)
        fetch_targets
        @targets[index]
      end

      alias :create! :create
      alias :build :create
      alias :new :create

      def delete(target)
        fetch_targets
        target.deleted = true
        @targets.delete(target)
      end

      def clear
        @targets = []
      end

      def count
        fetch_targets { |ts| ts.count }
      end

      alias :size :count
      alias :length :count

      def each
        fetch_targets

        if block_given?
          @targets.each { |val| yield val }
        else
          @targets.to_enum
        end
      end

      def targets
        fetch_targets
      end

      def persist!(create_new = false, new_parent = nil)
        @parent = new_parent if new_parent
        current_ids = parent.send(association.name).pluck(:id)
        new_ids = targets.map(&:id).compact

        targets.each do |target|
          if create_new
            target.model = target.model.dup
            target.model.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
            target.model.save
            target.persist!(create_new, target.model)
          else
            if current_ids.include?(target.id) && !new_ids.include?(target.id)
              # deleted
              target.delete
              target.persist!
            elsif target.id.nil? || current_ids.include?(target.id) || new_ids.include?(target.id)
              # new or changed/unchanged
              target.model.save
              target.persist!(create_new)

              unless target.deleted
                target.model.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
                target.model.save
              end
            end
          end
        end
      end

      private

      def fetch_targets
        if @targets.size == 0
          if block_given?
            yield parent.send(association.name)
          else
            @touched = true
            @targets = parent.send(association.name).map { |target| wrap(target) }
          end
        else
          if block_given?
            yield @targets
          else
            @targets
          end
        end
      end
    end

  end

end