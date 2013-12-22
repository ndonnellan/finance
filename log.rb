class Log
  SPACING = 15
  LEVEL_TAB = 2
  LEVEL_PREFIXES = ['total', 'year', 'month']
  class << self
    def recursive_print(hash, prefix="")
      
      print non_date_values_string(hash, prefix)
      should_print_header = true
      
      date_items = hash.select {|k,v| k.class == Fixnum }
      date_items.each do |k,v|
        @level += 1

        if @level <= @max_level
          if should_print_header
            print non_date_keys_string(v, LEVEL_PREFIXES[@level])
            should_print_header = false
          end

          recursive_print(v, k.to_s) 
        end
        @level -= 1
      end

    end
    def format(log, type='annual')
      @level = 0
        
      case type
      when 'annual'
        @max_level=1
      when 'monthly'
        @max_level=2
      else
        raise "Invalid log type #{type}"
      end

      # print non_date_keys_string(log, LEVEL_PREFIXES[@level])
      recursive_print(log)
    end

    def lvl_p(prefix)
      " "*LEVEL_TAB*@level + sprintf("%#{SPACING}s",prefix) 
    end

    def non_date_keys_string(hash, prefix="")
      keys = hash.keys.select {|k| k.class != Fixnum }.collect {|k| k.to_s }
      lvl_p(prefix) + keys.map{|s| sprintf("%#{SPACING}s",s)}.join(',') + "\n"
    end

    def non_date_values_string(hash, prefix="")
      values = hash.select {|k,v| k.class != Fixnum }.values
      lvl_p(prefix) + values.map do |v|
        if v.class == Hash
          " "*SPACING
        else
          sprintf("%#{SPACING}.0f", v)
        end
      end.join(',') + "\n"
    end
  end
end