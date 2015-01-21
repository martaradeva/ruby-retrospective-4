describe 'Command Line Toolkit' do

  RSpec::Matchers.define :render_as do |expected|
    unindent     = -> text { text.gsub(/^#{text.scan(/^\s*/).min_by{|l|l.length}}/, '') }
    rstrip_lines = -> text { text.lines.map(&:rstrip).join("\n") }

    match do |actual|
      actual_text   = rstrip_lines.call(UI::TextScreen.draw(&actual).to_s)
      expected_text = rstrip_lines.call(unindent.call(expected))

      expect(actual_text).to eq expected_text
    end

    def supports_block_expectations?
      true
    end
  end

  it 'simple puts debug' do
    UI::TextScreen.draw do 
      label text: '1'
      label text: '2'
    end
  end

  it 'arranges components horizontally by default' do
    expect do
      label text: '1'
      label text: '2'
      label text: '3'
    end.to render_as <<-RESULT
      123
    RESULT
  end

  it 'horizontal group orders elements horizontally' do
    expect do
      horizontal do
        label text: '1'
        label text: '2'
      end
    end.to render_as <<-RESULT
      12
    RESULT
  end

  it 'vertical group orders elements vertically' do
    expect do
      vertical do
        label text: '1'
        label text: '2'
      end
    end.to render_as <<-RESULT
      1
      2
    RESULT
  end

  it 'can create simple table' do
    expect do
      vertical do
        horizontal do 
          label text: '1'
          label text: '2'
        end
        horizontal do 
          label text: '3'
          label text: '4'
        end
      end
    end.to render_as <<-RESULT
      12
      34
    RESULT
  end

  it 'can create a transponded table' do
    expect do
      horizontal do
        vertical do 
          label text: '1'
          label text: '2'
        end
        vertical do 
          label text: '3'
          label text: '4'
        end
      end
    end.to render_as <<-RESULT
      13
      24
    RESULT
  end


  it 'can create a less simple table' do
    expect do
      vertical do
        horizontal do
          label text: '1'
          label text: '2'
          label text: '3'
        end
        horizontal do
          label text: '4'
          label text: '5'
          label text: '6'
        end
        horizontal do
          label text: '7'
          label text: '8'
          label text: '9'
        end
      end
    end.to render_as <<-RESULT
      123
      456
      789
    RESULT
  end

    it 'can create a COMPLICATED table' do
    expect do
      horizontal do
        vertical do
          label text: '1'
          label text: '2'
          label text: '3'
        end
        vertical do
          label text: '4'
          label text: '5'
          label text: '6'
        end
        vertical do
          label text: '7'
          label text: '8'
          label text: '9'
        end
      end
    end.to render_as <<-RESULT
      147
      258
      369
    RESULT
  end

  it 'wraps vertically-aligned components correctly in border' do
    expect do
      vertical border: '|' do
        label text: 'something'
        label text: 'some'
        label text: 'soommee'
      end
    end.to render_as <<-RESULT
      |something|
      |some     |
      |soommee  |
    RESULT
  end

  # it 'applies downcase to simple components' do
  #   expect do
  #     label text: 'SOME'
  #     label text: 'VERY', style: :downcase
  #   end.to render_as <<-RESULT
  #     SOMEvery
  #   RESULT
  # end
end
