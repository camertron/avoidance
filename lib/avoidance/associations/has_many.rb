# encoding: UTF-8

module Avoidance

  module Associations

    class HasManyAssociation < Association
      include Enumerable

      attr_reader :deleted_records

      def initialize(association, parent)
        super
        @deleted_records = []
        fetch_targets
      end

      define_method(:<<) do |new_target|
        @targets << wrap(new_target)
        @targets
      end

      alias :push :<<
      alias :add :<<

      define_method(:'+=') do |new_targets|
        @targets += new_targets.map { |target| wrap(target) }
        @targets
      end

      define_method(:'=') do |new_targets|
        @touched = true
        @targets = new_targets.map { |target| wrap(target) }
      end

      def create(attributes, &block)
        target = wrap(@association.klass.new(attributes, &block))
        @targets << target
        target
      end

      def first
        @targets.first
      end

      def last
        @targets.last
      end

      def [](index)
        @targets[index]
      end

      alias :create! :create
      alias :build :create
      alias :new :create

      def delete(target)
        target = wrap(target)
        target.deleted = true
        primary_key = target.model.class.primary_key.to_sym

        index = @targets.index do |t|
          target.send(primary_key) == t.send(primary_key)
        end

        @targets.delete_at(index) if index
        @deleted_records << target
      end

      def clear
        @deleted_records += @targets
        @targets.each { |t| t.deleted = true }
        @targets = []
      end

      def count
        @targets.count
      end

      alias :size :count
      alias :length :count

      def each
        if block_given?
          @targets.each { |val| yield val }
        else
          @targets.to_enum
        end
      end

      def targets
        @targets.compact
      end

      def persist!(create_new = false, new_parent = nil)
        @parent = new_parent if new_parent
        current_ids = parent.send(association.name).pluck(:id)
        new_ids = targets.map(&:id).compact

        if !create_new
          @deleted_records.each do |target|
            target.model.delete
          end
        end

        targets.each do |target|
          if create_new
            target.model = target.model.dup
            target.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
            target.persist!(create_new, target.model)
          else
            if target.id.nil? || current_ids.include?(target.id) || new_ids.include?(target.id)
              # new or changed/unchanged
              target.persist!(create_new)

              if target.deleted
                parent.send(association.name).delete(target.model)
              else
                target.model.send(:"#{association.foreign_key}=", parent.send(association.association_primary_key.to_sym))
                target.model.save
              end
            end
          end
        end
      end

      private

      def fetch_targets
        @targets = parent.send(association.name).map { |target| wrap(target) }
      end
    end

  end

end