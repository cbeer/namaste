require 'i18n'
module Namaste
  DUBLIN_KERNEL = { :type => 0, :who => 1, :what => 2, :when => 3, :where => 4 }
  PATTERN = Hash[*Namaste::DUBLIN_KERNEL.map { |k, v| [k, Regexp.new("^#{v}=.*")]}.flatten]
  PATTERN_CORE = /^\d=.*/
  PATTERN_EXTENDED = /=.*/

  class Dir < ::Dir
    def namaste selector = nil
      @namaste ||= Namaste::Base.new(self)
      @namaste[selector]
    end
  end

  class Base
    attr_reader :dir

    def initialize dir
      @dir = dir
    end

    def [] key=nil
      tags = []
      rgx = nil
      
      if args[:filter]
	if Namaste::PATTERN.key? args[:filter].to_sym
          rgx = Namaste::PATTERN[args[:filter].to_sym] 
	else
          rgx = Regexp.new("^#{args[:filter]}=.*")
	end
      else 
        rgx = Namaste::PATTERN_CORE
        rgx = Regexp(rgx, Namaste::PATTERN_EXTENDED) if args[:extended]
      end

      rgx = args[:regex] if args[:regex]
      
      tags |= self.select { |x| x =~ rgx  }
    end

    def []= key, value

    end
  end

  module Tag
    def self.filename tag, value
      n = "%s=%s" % [tag, self.elide(value)]
      n = n.slice(0...252) + "..." if n.length > 255
      n
    end

    class Base
      attr_accessor :dir, :tag
      def initialize dir, tag
        @file = file
        @tag = tag
        load_tag_modules
      end

      def set value
        write!
      end

      def get
        read!
      end

      private
      def write! value
        File.open(File.join(self.path, Tag.filename(value)), 'w') do |f|
          f.write(value)
        end
      end

      def read!
        open(file).read.strip
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
          def get
            matches = /([^_]+)_(\d+)\.(\d+)/.match(read!)  
	    { :type => nam[:value], :name => matches[1], :major => matches[2], :minor => matches[3] } if matches
          end
        end
      end
    end

    protected
    def self.elide value
      value = I18n.transliterate value
      value.gsub!(/[^A-Za-z0-9\-\._]+/, '_')
      value.gsub!(/_{2,}/, '_')
      value.gsub!(/^_|_$/, '_')
      encoded_value = value.downcase
    end
  end
end
