module UI

  class TextScreen

    def self.draw &block
      @screen = Screen.new
      @screen.instance_eval(&block)
      puts "screen.group.flatten.join '' in render = #{@screen.group.flatten.join ''}"
      @screen.group.flatten.join ""
    end

  end

  class Screen
    attr_accessor :group

    def initialize
      @group = []
    end

    def add_group &block
      @group << instance_eval(&block)
    end

    def label (text, style: nil, border: nil)
      @lbl = TextLabel.new(text)
      add_group {@lbl}
      @group
    end

    def vertical(style: nil, border: nil, &block)
      @partial = UI::Screen.compose &block
      @partial.map {|element| element << "\n"}
      @group << @partial
      pad_and_apply(border) if border
      @group
    end

    def horizontal(style: nil, border: nil, &block)
      @partial = UI::Screen.compose &block
      @partial.map { |element| [element] }
      @group << @partial
      if @group[0][0].is_a? Array 
        then @group[0] = transpose(@group[0])
      end
      pad_and_apply(border) if border
      @group
    end

    def pad_and_apply(border)
      elements = @group[0]
      elements = elements.map{|element| element.remove_newline}
      max_length = elements.max_by{|element| element.length}.length
      block = -> (element){[border + element.pad(max_length).to_s + border + "\n"]}
      elements = elements.map &block
      @group = [elements]
      @group
    end

    private

    def transpose(array)
      new_array = []
      (0..array.length-1).each do |index|
        new_array[index] = []
      end
      (0..array.length-1).each do |sub_array_index|
        array[sub_array_index].each_with_index do |element, index|
          new_array[index] << element.remove_newline
        end
      end
      new_array.map { |element| element << "\n" }
      new_array
    end

    def self.compose &block
      @screen = Screen.new
      @screen.instance_eval(&block)
    end

  end

  class TextLabel
    attr_reader :label

    def initialize(text:)
      @label = text
    end

    def inspect
      @label
    end

    def <<(string)
      @label << string
    end

    def remove_newline
      @label = @label.chop
      self
    end

    def to_s
      @label.to_s
    end

    def length
      @label.length
    end

    def pad(integer)
      white_space = integer - @label.length
      @label << " " * white_space
    end
  end
end
