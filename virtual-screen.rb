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

  # TODO:: not tested
  def start_position(format, auid, size, row_span, col_span)
    # Nothing goes in row 1; its for test
    temp_row_start = 2
    temp_col_start = 1

    if @active_column === 1
      temp_col_start = 1
    elsif @active_column === 2
      temp_col_start = 3
    elsif @active_column === 3
      temp_col_start = 5
    elsif @active_column === 4
      temp_col_start = 7
    elsif @active_column === 5
      temp_col_start = 9
    elsif @active_column === 6
      temp_col_start = 11
    else
      p 'nothing else will fit'
      return false
    end

    max_col = temp_col_start + 1
    max_row = 9

    # Large fills a section and always starts at row 4
    if size === 'large'
      @active_column += 2 # a large card uses 2 columns
      temp_row_start = 4
    end

    position = find_open_position(temp_row_start, temp_col_start, max_col, max_row, row_span, col_span)

    if !position.fits_in_section
      @active_column++
      return find_open_position(format, auid, size, row_span, col_span)
    else
      # We have a good row position and column position and verified that it fits
      row_start = position.row_position
      col_start = position.column_position

      #  Save the content on the virtualScreen matrix
      save_position(row_start, col_start, row_span, col_span)

      return {
        row_start: row_start,
        col_start: col_start,
      }
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

  # TODO: Not tested
  def find_open_position(temp_row_start, temp_col_start, max_col, max_row, row_span, col_span)
    p "find_open_position"

    column_position = (col_span === 1) ?
      find_column(temp_row_start, temp_col_start) : # hor calc
      temp_col_start # stack up

    row_position = find_row(temp_row_start, column_position)
    fits_in_section = check_fit(row_position, column_position, row_span, col_span)

    # Not exactly DRY but pragmatic
    if !fits_in_section && col_span === 1
      column_position = max_col
      row_position = find_row(temp_row_start, column_position)
      fits_in_section = check_fit(row_position, column_position, row_span, col_span)
    end

    return {
      column_position: column_position,
      fits_in_section: fits_in_section,
      row_position: row_position,
    }
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

  # TODO:: Not tested
  def check_fit(row, column, row_span, col_span)
    p "check_fit row: #{row}, col: #{column}, rowspan: #{row_span}, rowspan #{col_span}"

    i = row
    stop = row + row_span - 1 # Minus one becuse the span includes the start
    positions = []
    fits

    begin
      i.upto(stop) do
        # TODO: drop is not JS slice, check this
        positions.push(@virtual_screen[i].drop(column, column + col_span))
        i++
      end

      #  If there is not a 1 in the array that means all positions are open
      fits = !positions.flatten.include?(1)
    rescue
      fits = false
    end

    fits
  end
end
