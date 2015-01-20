module RBFS

  class Parser
    attr_accessor :string_to_parse

    def initialize(string)
      @string_to_parse = string
    end

    def parse_to_hash(class_name)
      result = {}
      block = -> (name, entity) {result[name] = class_name.parse(entity)}
      parse_all &block
      result
    end

    private

    def parse_all
      size = next_parameter!.to_i
      size.times do
        name = next_parameter!
        serialized = next_entity!
        yield name, serialized
      end
    end

    def next_parameter!
        chunk, string = @string_to_parse.split(":", 2)
        @string_to_parse = string
        chunk
    end

    def next_entity!
        length = next_parameter!.to_i
        chunk = @string_to_parse.slice! (0..length-1)
        chunk
    end
  end

  class File
    attr_accessor :data

    def initialize(*data)
      @data = data[0]
    end

    def data_type
      case @data
        when nil     then @data_type = :nil
        when String  then @data_type = :string
        when Symbol  then @data_type = :symbol
        when Numeric then @data_type = :number
        else              @data_type = :boolean
      end
    end

    def serialize
      self.data_type.to_s + ':' + @data.to_s
    end

    def self.parse(string)
      data_type, data_string = string.split(":", 2)
      file_content = parse_data(data_type, data_string)
      File.new (file_content)
    end

    private
    def self.parse_data(type, data)
      case type
        when "string"  then parsed = data
        when "symbol"  then parsed = data.to_sym
        when "number"  then parsed = parse_number(data)
        when "nil"     then parsed = nil
        when "boolean" then parsed = parse_boolean(data)
      end
    end

    def self.parse_boolean(data)
      if data == "true" then true else false end
    end

    def self.parse_number(data)
      if data.include? "." then data.to_f else data.to_i end
    end
  end

  class Directory
    attr_accessor :directories
    attr_accessor :files

    def initialize (files={}, directories={})
      @files       = files
      @directories = directories
    end

    def add_file(name, file)
      if !name.include? ":" then @files.merge!({ name => file }) end
    end

    def add_directory(name, *directory)
      if directory.length > 0
      then new_directory = {name => directory[0]}
      else new_directory = {name => RBFS::Directory.new}
      end
      @directories.merge!(new_directory)
    end

    def [](key)
      @directories[key] or @files[key]
    end

    def serialize
      files = serialize_similar(@files)
      directories = serialize_similar(@directories)
      "#{files}#{directories}"
    end

    def self.parse(string)
      parser = Parser.new(string)

      files =       parser.parse_to_hash (File)
      directories = parser.parse_to_hash (Directory)

      Directory.new(files, directories)
    end

    private

    def serialize_similar(objects_array)
      text = ""
      text << "#{objects_array.length.to_s}:"
      objects_array.each do |name, object|
        serialized = object.serialize
        text << "#{name}:#{serialized.length.to_s}:#{serialized}"
      end
      text
    end
  end
end
