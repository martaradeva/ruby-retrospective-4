module RBFS

  class Parser
    attr_accessor :string_to_parse

    def initialize
      @string_to_parse = ""
      @parsed_objects = {}
    end

    def self.parse_directory(string)
      #@string_to_parse = string
      #puts @string_to_parse
      parsed_directory = RBFS::Directory.new
      parsed_directory.files.merge! parse_all_objects(RBFS::File, string)
  parsed_directory.directories.merge! parse_all_objects(RBFS::Directory, string)
      parsed_directory
    end

    private

    def self.parse_all_objects(class_name, string)
      # puts @string_to_parse
      parsed_objects = {}
      number_of_objects = next!(string).to_i
      while number_of_objects > parsed_objects.length do
        puts string
        parsed_objects.merge! parse_single_object(class_name, string) end
      parsed_objects
    end

    def self.parse_single_object(class_name, string)
      #puts "to parse= #{string}"
      name = next!(string)
      length = next!(string)
      serialized = next!(string, length)
      #puts "name= #{name}, length= #{length} s= #{serialized}"
      parsed = class_name.parse(serialized)
      if string.length > 0 then parse_single_object(class_name, string) end
      @parsed_objects.merge! {name => parsed}
    end

    def self.next! (string, *piece_length)
      return "" if string.length == 0
      if piece_length.length > 0
        then string.slice! (0..piece_length[0].to_i-1)
        else chunk, string = string.split(":", 2)
        chunk
      end
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
        when "string" then parsed = data
        when "symbol" then parsed = data.to_sym
        when "number" then parsed = parse_number(data)
        when "nil"    then parsed = nil
        else               parsed = 'true'
      end
    end

    def self.parse_boolean(data)
      if data then true else false end
    end

    def self.parse_number(data)
      if data.include? "." then data.to_f else data.to_i end
    end
  end

  class Directory
    attr_accessor :directories
    attr_accessor :files

    def initialize
      @directories = {}
      @files = {}
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
      result = []
      result << serialize_similar(@files)
      result << serialize_similar(@directories)
      result.join ""
    end

    def serialize_similar(objects_array)
      text = []
      text << objects_array.length.to_s + ":"
      objects_array.each do |name, object|
        text << [name, object.serialize.length.to_s, object.serialize].join(":")
      end
      text
    end

    def self.parse(string)
      RBFS::Parser.parse_directory(string)
    end
  end

end
