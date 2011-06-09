require 'i18n'
module Namaste
  DUBLIN_KERNEL = { :type => 0, :who => 1, :what => 2, :when => 3, :where => 4 }
  PATTERN = Hash[*Namaste::DUBLIN_KERNEL.map { |k, v| [k, Regexp.new("^#{v}=.*")]}.flatten]
  PATTERN_CORE = /^\d=.*/
  PATTERN_EXTENDED = /=.*/
  
  module Mixin
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
    
    def namaste_tags args = {}
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

    def namaste args = {}
      namaste_tags(args).map { |x|  get_namaste x }
    end

    def dirtype
      namaste(:filter => :type).map do |nam| 
        matches = /([^_]+)_(\d+)\.(\d+)/.match(nam[:value])  
	      { :type => nam[:value], :name => matches[1], :major => matches[2], :minor => matches[3] } if matches
      end
    end

    private
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
