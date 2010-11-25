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
      namaste_tags(args).map{ |x|
        t, v = x.split '='
        [t, x, get_namaste(x)]
      }
    end

    private
    def set_namaste tag, value
      File.open(File.join(self.path, make_namaste(tag, value)), 'w') do |f|
        f.write(value)
      end
    end

    def get_namaste tag
      open(File.join(self.path, tag)).read.strip
    end
    
    def make_namaste tag, value
      encoded_value = nil
      encoded_value ||= value.parameterize '_' if value.respond_to? :parameterize
      encoded_value ||= value
      "%s=%s" % [tag, encoded_value]
    end

  end

  class Dir < ::Dir
   include Namaste::Mixin
  end
end
