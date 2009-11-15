module Sieve
  module ShouldaMacros
    class Test::Unit::TestCase
      def self.should_be_sieved
        klass = described_type rescue model_class
        should "be filterable" do
          assert klass.respond_to?(:filter_by, true), 'should respond to filter_by'
          assert klass.respond_to?(:filtering_on), 'should respond to filtering_on'
          assert klass.respond_to?(:filter), 'should respond to filter'
          assert klass.respond_to?(:sieve_class), 'should respond to sieve class'
        end
        
        should "return it's base class as the sieve class" do
          assert_equal klass.base_class, klass.sieve_class, 'should have the same base class and sieve class'
        end
      end
      
      def self.should_filter_on(attributes = [])
        attributes = [attributes] unless attributes.kind_of?(Array)
        klass = described_type rescue model_class
        attributes.each { |attribute|
          should "filter on #{attribute}" do
            assert klass.filtering_on.include?(attribute)
          end
        }
      end
    end
  end
end