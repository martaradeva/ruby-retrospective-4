module UI

  class TextScreen

    def self.draw &block
      screen = Screen.new
      screen.instance_eval(&block)
      puts screen.render.inspect
      screen.render
    end
  end

  class Screen
    def initialize()
      @screen = []
    end

    def horizontal &block
      yield
      @screen = [@screen, "\n"]
      puts @screen.inspect
    end

    def vertical &block
      yield
      @screen.map! {|group| [group] << "\n"}
      @screen.last.pop
    end

    def render
      @screen.join
    end

    def label (text, style: nil, border: nil)
      label = TextLabel.new(text)
      @screen << label.label
    end

  end

  class TextLabel
    attr_reader :label

    def initialize(text:)
      @label = text
    end

  end

    def border #border will be defined as a patch of method_missing
    end

    def style # style will be defined as a patch of method_missing
    end

end