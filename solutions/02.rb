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

  # def &(argument)
  #   self and argument
  # end

  # def |(argument)
  #   self or argument
  # end
end

class Filter
  def initialize (&block)
    @filter = block
  end

  def accepts?(number)
        return true if @filter.call(number)
  end
end

class TypeFilter
  def initialize (data_type)
    @data_type = data_type
  end

  def accepts?(number)
    case @data_type
      when :integer then Filter.new {|n| n.is_a? Integer}.accepts?(number)
      when :complex then Filter.new {|n| n.is_a? Complex}.accepts?(number)
      when :real then Filter
        .new {|n| n.is_a? Float or n.is_a? Rational}.accepts?(number)
    end
  end
end

class SignFilter
  def initialize (data_type)
    @data_type = data_type
  end

  def accepts?(sign)
    case @data_type
      when :positive     then Filter.new {|n| n >  0}.accepts?(sign)
      when :non_positive then Filter.new {|n| n <= 0}.accepts?(sign)
      when :negative     then Filter.new {|n| n <  0}.accepts?(sign)
      when :non_negative then Filter.new {|n| n >= 0}.accepts?(sign)
    end
  end
end