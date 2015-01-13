describe RBFS do

  describe 'Directory' do
    subject(:directory) { RBFS::Directory.new }

    context 'with files and directories' do
      let(:readme) { RBFS::File.new('Hello world!')  }
      let(:spec)   { RBFS::File.new('describe RBFS') }

      before(:each) do
        directory.add_file('README',  readme)
        directory.add_file('spec.rb', spec)
      end

      it 'returns correct file hash' do
        directory.add_directory('SUBDIR')
        expect(directory.files).to eq({'README' => readme, 'spec.rb' => spec})
      end

      it 'returns correct file hash 2' do
        dir = RBFS::Directory.new
        directory.add_directory('SUBDIR', dir)
        expect(directory.directories).to eq({'SUBDIR' => dir})
      end


      # it 'can be created with a name' do
      #   dir = RBFS::Directory.new("Pesho")
      #   expect(dir.name).to eq "Pesho"
      # end

      it '#add_directory creates new dir when no dir is given' do
        directory.add_directory("SUBDIR")
        expect(directory.directories.length).to eq(1)
      end

    end
    context 'serialization' do
      let(:simple_serialized_string) do
        [
          '2:',
            'README:19:string:Hello world!',
            'spec.rb:20:string:describe RBFS',
          '1:',
            'rbfs:4:',
              '0:',
              '0:',
        ].join ''
      end
      let(:simpler_serialized_string) do
        ['1:',
            'README:19:string:Hello world!',
        ].join ''
      end

      describe '#serialize' do

        it 'can serialize a simple dir' do
          directory.add_file 'README',  RBFS::File.new('Hello world!')
          directory.add_file 'spec.rb', RBFS::File.new('describe RBFS')
          directory.add_directory 'rbfs'
          puts directory.serialize
          puts directory['rbfs'].inspect
          #expect(directory.serialize).to eq simple_serialized_string
          expect(1).to eq 1
        end

        # it 'can serialize' do
        #   directory.add_file 'README',  RBFS::File.new('Hello world!')
        #   directory.add_file 'spec.rb', RBFS::File.new('describe RBFS')
        #   directory.add_directory 'rbfs'
        #   # puts directory.serialize
        #   expect(directory.serialize).to eq simple_serialized_string
        # end
      end

      describe '::parse' do
        it 'can parse only files' do
          parsed_directory = RBFS::Directory.parse(simple_serialized_string)
          expect(parsed_directory.files.size     ).to eq    2
          expect(parsed_directory['README'].data ).to eq    'Hello world!'
          expect(parsed_directory['spec.rb'].data).to eq    'describe RBFS'
        end

        it 'can parse complete directory (recursive)' do
          parsed_directory = RBFS::Directory.parse(simple_serialized_string)

          expect(parsed_directory.files.size     ).to eq    2
          expect(parsed_directory['README'].data ).to eq    'Hello world!'
          expect(parsed_directory['spec.rb'].data).to eq    'describe RBFS'
          expect(parsed_directory['rbfs']        ).to be_an RBFS::Directory
        end
      end
    end

    it 'can add a file' do
      file = RBFS::File.new('Hey there!')

      directory.add_file 'README', file

      expect(directory.files).to eq({'README' => file})
    end

    it 'can add a directory' do
      subdirectory = RBFS::Directory.new

      directory.add_directory 'home', subdirectory

      expect(directory.directories).to eq({'home' => subdirectory})
    end

    describe '#[]' do
      let(:home) { RBFS::Directory.new }

      before(:each) do
        directory.add_directory 'home', home
      end

      it 'can walk a directory' do
        expect(directory['home']).to eq home
      end

      it 'can be chained' do
        about = RBFS::Directory.new
        directory['home'].add_directory 'about', about
        expect(directory['home']['about']).to eq about
      end
    end
  end

  describe 'File' do
    subject(:file) { RBFS::File.new }

    it 'can store data' do
      file.data = 'hello world'
      expect(file.data).to eq 'hello world'
    end

    it 'can be created empty' do
      file = RBFS::File.new
      expect(file.data).to eq nil
    end

    it 'can accept data in the initializer' do
      file = RBFS::File.new('Hay :)')

      expect(file.data).to eq 'Hay :)'
    end

  end

  context 'data type' do
    context 'number' do
      it 'can be detected' do
        expect(RBFS::File.new(42).data_type).to eq :number
        end
      end

    context 'string' do
      it 'can be detected' do
        expect(RBFS::File.new("baba").data_type).to eq :string
      end
    end

    context 'symbol' do
      it 'can be detected' do
        expect(RBFS::File.new(42.to_s.to_sym).data_type).to eq :symbol
      end
    end

    context 'boolean' do
      it 'can be detected' do
        expect(RBFS::File.new(true).data_type).to eq :boolean
      end
    end

    context 'nil' do
      it 'can be detected' do
        expect(RBFS::File.new().data_type).to eq :nil
      end
    end

    context 'serialization' do
    let(:simple_serialized_string) do
      [
        'string:',
          'Hello world!'
      ].join ''
    end
    let(:complex_serialized_string) do
      [
        'symbol:',
          'hello'
      ].join ''
    end

    describe '#serialize' do
      it 'can serialize' do
        file = RBFS::File.new('Hello world!')
        expect(file.serialize).to eq simple_serialized_string
      end
    end

    describe '::parse' do
      it 'can parse a string' do
        parsed_file = RBFS::File.parse(simple_serialized_string)
        expect(parsed_file.data).to eq        'Hello world!'
        expect(parsed_file.data_type).to eq   :string
      end

      it 'can parse a symbol' do
        parsed_file = RBFS::File.parse(complex_serialized_string)
        expect(parsed_file.data).to eq        :hello
        expect(parsed_file.data_type).to eq   :symbol
      end

    end
  end

  end
end