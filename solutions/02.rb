class NumberSet
include Enumerable

  def initialize
    @number_set = []
  end

  def empty?
    ! @number_set.any?
  end

  def each(&block)
    @number_set.each(&block)
  end

  def size
    @number_set.count
  end

  def <<(number)
     @number_set << number unless @number_set.include?(number)
    self
  end

  def [](filter)
    filtered_set = NumberSet.new
    self.each {|current| filtered_set << current if filter.accepts?(current)}
    filtered_set
  end
end

class Filter
  def initialize(&block)
    @filter = block
  end

  def accepts?(number)
    return true if @filter.call(number)
  end

  def &(other)
    Filter.new { |number| self.accepts?(number) and other.accepts?(number) }
  end

  def |(other)
    Filter.new { |number| self.accepts?(number) or other.accepts?(number) }
  end
end

class TypeFilter < Filter
  def initialize(data_type)
    @data_type = data_type
  end

  def accepts?(number)
    criterion = -> {}
    case @data_type
      when :integer then criterion = -> (n) { n.is_a? Integer }
      when :complex then criterion = -> (n) { n.is_a? Complex }
      when :real    then criterion = -> (n) { n.is_a? Float or n.is_a? Rational }
    end
    Filter.new(&criterion).accepts?(number)
  end
end

class SignFilter < Filter
  def initialize(data_type)
    @data_type = data_type
  end

  def accepts?(sign)
    criterion = -> {}
    case @data_type
      when :positive     then criterion = -> (n) { n >  0 }
      when :non_positive then criterion = -> (n) { n <= 0 }
      when :negative     then criterion = -> (n) { n <  0 }
      when :non_negative then criterion = -> (n) { n >= 0 }
    end
    Filter.new(&criterion).accepts?(sign)
  end
end
