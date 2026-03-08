require 'tty-reader'
require 'tty-live'

module TTY
  class Draft
    VERSION = '0.1.2'

    attr_reader :done

    def initialize(prompt: ->(n){''})
      @prompt = prompt
      new_draft
    end

    def gets
      reader = Reader.new
      reader.subscribe(self)
      live = Live.new

      live.update(edited)
      loop do
        reader.read_char
        if done
          live.update(edited)
          reader.unsubscribe(self)
          puts live.show
          return to_string(@chars).tap{new_draft}
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
      when :home, :ctrl_a
        @col = 0
      when :end, :ctrl_e
        @col = current_row.size
      when :return
        insert_row
      else
        return insert_row if event.value == "\n"
        current_row.insert(@col, event.value)
        @col += 1
      end
    end

    private

    def edited
      render to_string(@chars)
    end

    def editing
      copy = @chars.dup
      copy[@row] = current_row.dup
      copy[@row][@col] = "\e[7m#{copy[@row][@col] || ' '}\e[27m"
      render to_string(copy)
    end

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
      chars.map(&:join).join("\n")
    end

    def render(str)
      lines = str.empty? ? [''] : str.each_line
      lines.each_with_index.map do |line, i|
        @prompt[i] + line
      end.join
    end
  end
end
