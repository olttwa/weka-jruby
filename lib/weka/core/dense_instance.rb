module Weka
  module Core
    java_import 'weka.core.DenseInstance'

    class DenseInstance
      java_import 'java.util.Date'
      java_import 'java.text.SimpleDateFormat'

      def initialize(data, weight: 1.0)
        if data.is_a?(Integer)
          super(data)
        else
          super(weight, to_java_double(data))
        end
      end

      def attributes
        enumerate_attributes.to_a
      end

      def each_attribute
        if block_given?
          enumerate_attributes.each { |attribute| yield(attribute) }
        else
          enumerate_attributes
        end
      end

      def each_attribute_with_index
        enumerate_attributes.each_with_index do |attribute, index|
          yield(attribute, index) if block_given?
        end
      end

      def to_a
        to_double_array.each_with_index.map do |value, index|
          value_from(value, index)
        end
      end

      alias values       to_a
      alias values_count num_values

      private

      def to_java_double(values)
        data = values.map do |value|
          ['?', nil].include?(value) ? Float::NAN : value
        end

        data.to_java(:double)
      end

      def value_from(value, index)
        return '?'   if value.nan?
        return value if dataset.nil?

        attribute = attribute_at(index)

        if attribute.date?
          format_date(value, attribute.date_format)
        elsif attribute.numeric?
          value
        elsif attribute.nominal?
          attribute.value(value)
        end
      end

      def attribute_at(index)
        return attributes[index] unless dataset.class_attribute_defined?

        if dataset.class_index == index
          class_attribute
        elsif index > dataset.class_index
          attributes[index - 1]
        else
          attributes[index]
        end
      end

      def format_date(value, format)
        formatter = SimpleDateFormat.new(format)
        formatter.format(Date.new(value))
      end
    end
  end
end
