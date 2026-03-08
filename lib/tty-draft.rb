require 'tty-reader'
require 'tty-live'

module TTY
  class Draft
    VERSION = '0.1.1'

    class << self
      def gets
        draft = new
        reader = Reader.new
        reader.subscribe(draft)
        live = Live.new

        loop do
          reader.read_char
          if draft.done
            live.update('')
            reader.unsubscribe(draft)
            print live.show
            return draft.edited
          end
          live.update(draft.editing)
          print live.hide
        end
      end
    end

    attr_reader :done

    def initialize
      @chars = [[]]
      @row = 0
      @col = 0
    end

    def keypress(event)
      @done = false
      case event.key.name
      when :ctrl_d, :ctrl_z
        @done = true
      when :backspace
        if @col > 0
          @col -= 1
          return delete_char
        end
        if @row > 0
          @col = @chars[@row - 1].size
          @chars[@row - 1] += delete_row
          return @row -= 1
        end
      when :delete
        return delete_char if @col < current_row.size
        @chars[@row] = current_row + ((@row += 1) && delete_row.tap{@row -= 1})
      when :left
        return @col -= 1 if @col > 0
        return if @row <= 0
        @row -= 1
        @col = current_row.size
      when :right
        return @col += 1 if @col < current_row.size
        return if (@row + 1) >= @chars.size
        @row += 1
        @col = 0
      when :up
        @row -= 1 if @row > 0
        fix_col
      when :down
        @row += 1 if (@row + 1) < @chars.size
        fix_col
      when :return
        insert_row
      else
        return insert_row if event.value == "\n"
        current_row.insert(@col, event.value)
        @col += 1
      end
    end

    def edited
      to_string(@chars)
    end

    def editing
      copy = @chars.dup
      copy[@row] = current_row.dup
      copy[@row][@col] = "\e[7m#{copy[@row][@col] || ' '}\e[27m"
      to_string(copy)
    end

    private

    def delete_char
      current_row.delete_at(@col)
    end

    def current_row
      @chars[@row] ||= []
    end

    def delete_row
      @chars.delete_at(@row) || []
    end

    def insert_row
      @chars.insert(@row + 1, current_row[@col..-1] || [])
      @chars[@row] = current_row[0...@col]
      @row += 1
      @col = 0
    end

    def fix_col
      @col = [@col, current_row.size].min
    end

    def to_string(chars)
      chars.map{|r| r.empty? ? ' ' : r.join }.join("\n")
    end
  end
end
