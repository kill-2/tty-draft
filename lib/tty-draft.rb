require 'tty-reader'
require 'tty-live'

module TTY
  class Draft
    VERSION = '0.1.2'

    attr_reader :done

    def initialize
      new_draft
    end

    def gets
      reader = Reader.new
      reader.subscribe(self)
      live = Live.new

      loop do
        reader.read_char
        if done
          puts
          live.update('')
          reader.unsubscribe(self)
          print live.show
          return edited.tap{new_draft}
        end
        live.update(editing)
        print live.hide
      end
    end

    def keypress(event)
      @done = false
      case event.key.name
      when :ctrl_d, :ctrl_z
        history << @chars
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
        if @row > 0
          @row -= 1
          return fix_col
        end
        if @work > 0
          return load_history(@work -= 1)
        end
      when :down
        if (@row + 1) < @chars.size
          @row += 1
          return fix_col
        end
        if @work + 1 < @workspaces.size
          return load_history(@work += 1)
        end
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

    def new_draft
      @chars = [[]]
      @row = 0
      @col = 0
      (@workspaces = [])[(@work = history.size)] = @chars
    end

    def history
      @history ||= []
    end

    def load_history(i)
      @chars = (@workspaces[i] ||= @history[i].map(&:dup))
      @row = @chars.size - 1
      @col = current_row.size
    end

    def fix_col
      @col = [@col, current_row.size].min
    end

    def to_string(chars)
      chars.map{|r| r.empty? ? ' ' : r.join }.join("\n")
    end
  end
end
