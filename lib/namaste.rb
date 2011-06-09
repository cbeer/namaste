require 'i18n'
# The Namaste module conains a Mixin module to include into a class.

# namaste = Dir.new('.').namaste
# namaste[:who] = "John Doe"
# namaste[:what] = "John's Manifesto"

module Namaste
  # @return [Hash] of Namaste mappings for integer and type value
  DUBLIN_KERNEL = { :type => 0, :who => 1, :what => 2, :when => 3, :where => 4 }
  
  # @return [Hash] of regular expressions matching the Namaste::DUBLIN_KERNAL Hash
  PATTERN = Hash[*Namaste::DUBLIN_KERNEL.map { |k, v| [k, Regexp.new("^#{v}=.*")]}.flatten]
  
  # @return [Regexp] of standard Namaste file name pattern
  PATTERN_CORE = /^\d=.*/

  # @return [Regexp] of the possible exteneded Namaste file name pattern
  PATTERN_EXTENDED = /=.*/

  class Dir < ::Dir
    # Return the file contents of a Namaste given a filter and regexp
    # @param [Symbol, Hash] an arguments hash that accepts filter, extended, and regex arguments
    # @return [String, Array] the contents of the Namaste
    def namaste selector = nil
      @namaste ||= Namaste::Base.new(self)
      return @namaste.filter(selector) if selector.is_a? Hash
      @namaste[selector]
    end
  end

  class Base
    attr_reader :dir

    # Initialize a new Namaste directory
    def initialize dir
      @dir = dir
    end

    # Compatibility with Namaste <0.2
    # @param [Hash] args
    # @return [String, Array]
    def filter args
      return self[args[:filter]] if args[:filter]
      return self[:extended] if args[:extended]
      self[]
    end

    # Get the namaste values for a key
    # @param [Symbol] 
    def [] key=nil
      rgx = Namaste::PATTERN[key]
      rgx ||= Regexp.new("^#{Regexp.escape(key)}=")
      rgx ||= Namaste::PATTERN_EXTENDED if key == :extended
      rgx ||= Namaste::PATTERN_CORE if key == nil
      dir.select { |x| x =~ rgx }.map { |x| Tag::Base.new(self, x) }
    end

    # Append a new namaste value
    # @param [String] key 
    # @param [String] value
    # @return [Namaste::Tag::Base] 
    def []= key, value
      Tag::Base.new(self, key).set(value)
    end
  end

  module Tag
    # Create a filename for a namaste key/value pair
    # @return [String]
    def self.filename tag, value
      n = "%s=%s" % [tag, self.elide(value)]
      n = n.slice(0...252) + "..." if n.length > 255
      n
    end

    class Base
      attr_accessor :dir, :tag
      def initialize dir, tag
        @dir = dir
        @tag = tag
        load_tag_modules
      end

      # @param [String] value 
      def set value
        write!
      end

      # @return [String]
      def get
        read!
      end
      
      # delete the tag
      def delete
        FileUtils.rm(path)
      end

      private
      def write! value
        File.open(path, 'w') do |f|
          f.write(value)
        end
      end

      def read!
        open(path).read.strip
      end

      def path
        File.join(@dir.path, Tag.filename(value))
      end

      def filename value
        Tag.filename(tag, value)
      end

      def elide value
        Tag.elide(value)
      end

      def load_tag_modules
        case @tag
          when 0
            self.extend(Tag::Dirtype)
        end
      end
    end

    module Dirtype
      def self.extended(base)
        base.instance_eval do
          # @return [Hash] with the Dflat info broken out into its individual components of type, name, major, and minor.
          def get
            matches = /([^_]+)_(\d+)\.(\d+)/.match(read!)  
	    { :type => nam[:value], :name => matches[1], :major => matches[2], :minor => matches[3] } if matches
          end
        end
      end
    end

    protected
    # transliterate and truncate the value
    # @param [String] value
    # @return [String] ASCII string
    def self.elide value
      value = I18n.transliterate value
      value.gsub!(/[^A-Za-z0-9\-\._]+/, '_')
      value.gsub!(/_{2,}/, '_')
      value.gsub!(/^_|_$/, '_')
      encoded_value = value.downcase
    end
  end

  class Dir < ::Dir
    include Namaste::Mixin
  end
  
end
