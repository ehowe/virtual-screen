class VirtualScreen
  @active_column = 1
  @virtual_screen = nil

  def initialize(total_columns, total_rows)
    rows = total_rows.times.collect do |i|
      i + 1
    end

    @virtual_screen = rows.reduce({}) do |screen, row_number|
      screen[row_number] = total_columns.times.collect do |i|
        0
      end

      screen
    end

    # Set first row to all ones so it cannot be used for card content
    @virtual_screen[1].each_index do |i|
      @virtual_screen[1][i] = 1
    end
  end

  def log_screen
    p @virtual_screen
  end
end
