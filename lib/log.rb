class Log
  SPACING = 13
  LEVEL_TAB = 2
  LEVEL_PREFIXES = ['total', 'year', 'month']
  class << self

    def recursive_print(hash, prefix="")
      @level ||= 0     
      @max_level ||= 0 
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
    def format(log, type='annual', spacing=nil)
      @spacing = spacing
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

    def format_multiple(logs, type='annual', spacing=nil)
      combined_log = {}
      logs.each do |log|
        combined_log = nested_merge(combined_log, log) do |key, ov, nv|
          ov = ov.class == Array ? ov : [ov]
          ov << nv
        end
      end
      format(combined_log, type, spacing)
    end

    def format_summary(logs, type='annual', spacing=nil, &block)
      combined_log = {}
      logs.each do |log|
        combined_log = nested_merge(combined_log, log) do |key, ov, nv|
          ov = ov.class == Array ? ov : [ov]
          ov << nv
        end
      end

      @array_handler = block

      format(combined_log, type, spacing)
    end

    def nested_merge(hash1, hash2, &block)
      hash1.merge(hash2) do |key, old_value, new_value|
        if old_value.class == Hash
          nested_merge(old_value, new_value, &block)
        else
          block.call(key, old_value, new_value)
        end
      end
    end

    def spacing
      @spacing || SPACING
    end

    def lvl_p(prefix)
      " "*LEVEL_TAB*@level + sprintf("%#{spacing}s",prefix) 
    end

    def non_date_keys_string(hash, prefix="")
      keys = hash.keys.select {|k| k.class != Fixnum }.collect {|k| k.to_s }
      lvl_p(prefix) + keys.map{|s| sprintf("%#{spacing}s",s)}.join(',') + "\n"
    end

    def non_date_values_string(hash, prefix="")
      values = hash.select {|k,v| k.class != Fixnum }.values
      lvl_p(prefix) + values.map do |v|
        if v.class == Hash
          " "*spacing
        elsif v.class == Array
          if @array_handler
            sprintf("%#{spacing}s", @array_handler.call(v).to_s )
          else
            sprintf("%#{spacing}s", v.map {|e| e.to_s }.join("| "))
          end
        else
          sprintf("%#{spacing}s", v.to_s)
        end
      end.join(',') + "\n"
    end
  end
end