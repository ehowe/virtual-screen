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
  def save_position(row_start, col_start, row_span, col_span)
    Array.new(row_span).each_index do |row_span_i|
      Array.new(col_span).each_index do |col_span_i|
        row = row_span_i + row_start
        col = col_span_i + col_start # TODO: we pulled a -1 from here
        @virtual_screen[row][col] = 1
      end
    end

    log_screen
  end
  def find_column(row, start_column)
    # row is constant
    column_position   = start_column
    column_index      = start_column - 1
    next_column_index = start_column

    if @virtual_screen[row][column_index] == 1 && @virtual_screen[row][next_column_index] == 1
      column_position = start_column
    elsif @virtual_screen[row][column_index] == 1
      column_position = start_column + 1
    end

    column_position
  end

  def find_row(start_row, column)
    # column is constant
    column_index = column - 1
    possible_rows = @virtual_screen.keys
      .sort
      .drop(start_row - 1) # TODO: drop os not JS slice, check this

    i = possible_rows.find_index do |row_number|
      @virtual_screen[row_number][column_index] == 0
    end

    start_row + i
  end
end
