  class String
    def next_by_length! (number)
      self.slice! (0..number.to_i-1)
    end

    def next_by_column!
      chunk = self.split(":", 2)[0]
      self.slice! (0 .. chunk.length)
      chunk
    end

    def read_next_file!
      file_name = self.next_by_column!
      file_length = self.next_by_column!
      file_serialized = self.next_by_length!(file_length)
      [file_name, RBFS::File.parse(file_serialized)]
    end

    def read_next_dir!
      dir_name = self.next_by_column!
      dir_length = self.next_by_column!
      dir_serialized = self.next_by_length!(dir_length)
      [dir_name, RBFS::Directory.parse(dir_serialized)]
    end
  end

module RBFS

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
    attr_reader :directories
    attr_reader :files

    def initialize
      @directories = {}
      @files = {}
    end

    # def inspect
    #   "files: #{@files.length}, directories: #{@directories.length}"
    # end

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
      parsed_directory = Directory.new
      number_of_files = string.next_by_column!
      number_of_files.to_i.times do
        file_hash = string.read_next_file!
        parsed_directory.add_file(file_hash[0], file_hash[1])
      end
      number_of_directories = string.next_by_column!
      number_of_directories.to_i.times do
        directory_hash = string.read_next_dir!
        parsed_directory.add_directory(directory_hash[0], directory_hash[1])
      end
      parsed_directory
    end
  end

end

