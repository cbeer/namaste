require 'i18n'
# The Namaste module conains a Mixin module to include into a class.

# class MyNamaste
#   include Namaste::Mixin
# end
# MyNamaste.new
# MyNamaste.who = "John Doe"
# MyNamaste.what = "John's Manifesto"

module Namaste
  # @return [Hash] of Namaste mappings for integer and type value
  DUBLIN_KERNEL = { :type => 0, :who => 1, :what => 2, :when => 3, :where => 4 }
  
  # @return [Hash] of regular expressions matching the Namaste::DUBLIN_KERNAL Hash
  PATTERN = Hash[*Namaste::DUBLIN_KERNEL.map { |k, v| [k, Regexp.new("^#{v}=.*")]}.flatten]
  
  # @return [Regexp] of standard Namaste file name pattern
  PATTERN_CORE = /^\d=.*/

  # @return [Regexp] of the possible exteneded Namaste file name pattern
  PATTERN_EXTENDED = /=.*/
  
  module Mixin
    # When this Mixin module is included this will define getters and setters on your class for each of the keys in Namaste::DUBLIN_KERNAL.
    def self.included base
      Namaste::DUBLIN_KERNEL.each do |k,v|
        base.class_eval do
	        define_method(k.to_s) do |*args|
            namaste(:filter => k)
	        end

	        define_method(k.to_s+'=') do |*args|
	          set_namaste v, *args
	        end
	      end
      end
    end

    # Return the file contents of a Namaste given a filter and regexp
    # @param [Hash] an arguments hash that accepts filter, extended, and regex arguments
    # @return [String] the contents of the Namaste
    def namaste args = {}
      namaste_tags(args).map { |x|  get_namaste x }
    end

    # @return [Hash] with the Dflat info broken out into its individual components of type, name, major, and minor.
    def dirtype
      namaste(:filter => :type).map do |nam| 
        matches = /([^_]+)[|\/](\d+)\.(\d+)/.match(nam[:value])  
	      { :type => nam[:value], :name => matches[1], :major => matches[2], :minor => matches[3] } if matches
      end
    end

    private
    
    # Get an array of namaste tags that match the filter and regex provided.
    # @param [Hash] an arguments hash that accepts filter, extended, and regex arguments
    # @return [Array] an array of Namaste tags
    def namaste_tags args = {}
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
      
      self.select { |x| x =~ rgx  }
    end
    
    def set_namaste tag, value
      File.open(File.join(self.path, make_namaste(tag, value)), 'w') do |f|
        f.write(value)
      end
    end

    def get_namaste namaste_tag
      n = {}
      name, tvalue = namaste_tag.split '='
      n[:file] = namaste_tag
      n[:name] = name
      n[:value] = open(File.join(self.path, namaste_tag)).read.strip
      n
    end
    
    def make_namaste tag, value
      value = I18n.transliterate value
      value.gsub!(/[^A-Za-z0-9\-\._]+/, '_')
      value.gsub!(/_{2,}/, '_')
      value.gsub!(/^_|_$/, '_')
      encoded_value = value.downcase

      n = "%s=%s" % [tag, encoded_value]
      n = n.slice(0...252) + "..." if n.length > 255
      n
    end

  end

  class Dir < ::Dir
    include Namaste::Mixin
  end
  
end
