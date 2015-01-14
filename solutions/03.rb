module RBFS

  class Parser
    attr_accessor :string_to_parse

    def initialize
    end

    def self.parse_directory(string)
      @string_to_parse = string
      parsed_directory = RBFS::Directory.new
      parsed_directory.files.merge! parse_all_objects(RBFS::File)
      parsed_directory.directories.merge! parse_all_objects(RBFS::Directory)
      parsed_directory
    end

    private

    def self.parse_all_objects(klass)#klass is RBFS::File or RBFS::Directory
      parsed_objects = {}
      number_of_objects = next!.to_i
      number_of_objects.times do
        parsed_objects.merge! parse_single_object(klass)
      end
      parsed_objects
    end

    def self.parse_single_object(klass)
      name = next!
      length = next!
      serialized = next!(length)
      parsed = klass.parse(serialized)
      {name => parsed}
    end

    def self.next! (*piece_length)
      if piece_length.length > 0 
        then @string_to_parse.slice! (0..piece_length[0].to_i-1)
        else chunk, @string_to_parse = @string_to_parse.split(":", 2)
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
        when String                    then @data_type = :string
        when Symbol                    then @data_type = :symbol
        when Numeric                   then @data_type = :number
        when (TrueClass or FalseClass) then @data_type = :boolean
        else                                @data_type = :nil
      end
    end

    def serialize
      self.data_type.to_s + ':' + @data.to_s
    end

    def self.parse(string)
      data_type, data_string = string.split(":", 2)
      file_content = parse_data(data_type, data_string)
      # file_content = parse_data *string.split(":", 2) # I don't really understand what the wilcard goes for
      # http://fmi.ruby.bg/lectures/05-blocks-procs-parallel-assignment-classes-enumerable#41
      File.new (file_content)
    end

    private
    def self.parse_data(type, data)
      case type
        when "string" then parsed = data
        when "symbol" then parsed = data.to_sym
        when "number" then parsed = parse_number(data)
        when "boolean" then (data == "true") ? parsed = true : parsed = false
        when "" then parsed = nil
      end
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
      then new_dir = {name => directory[0]}
      else new_dir = {name => RBFS::Directory.new}
      end
      @directories.merge!(new_dir)
    end

    def [](key)
      @directories[key] or @files[key]
    end

    def serialize
      result = ''
      result << @files.length.to_s + ":"
      @files.each do |name, file| 
        result << [name, file.serialize.length.to_s, file.serialize].join(":")
      end
      result << @directories.length.to_s + ":"
      @directories.each do |name, directory|
        result << name << ":"
        result << directory.serialize
      end
      result
    end

    def self.parse(string)
      RBFS::Parser.parse_directory(string)
    end
  end
  
end
