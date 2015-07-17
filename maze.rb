def read_maze
  $stdin.read
end

def maze
  unless @cached_maze
    @cached_maze = read_maze.split("\n").map {|str| str.split(//)}
  end
  @cached_maze
end

def laser_pos(maze)
  row = maze.find_index { |row| row.include? '@' }
  col = maze.map { |r| r.find_index '@' }.reduce { |memo, obj| memo || obj }
  [row, col]
end

def object_at(row_num, col_num)
  return nil if row_num < 0 || col_num < 0
  row = maze[row_num] || []
  row[col_num]
end

def make_dir_func(params)
  -> (direction) do
    next_direction = params[direction]
    raise 'Wrong symbol' if !next_direction
    next_direction
  end
end

NEXT_DIR_FUNC_FROM_SYMBOL = {
  '-' => -> (direction) { direction },
  '@' => -> (direction) { direction },
  'v' => -> (_) { :s },
  '<' => -> (_) { :w },
  '^' => -> (_) { :n },
  '>' => -> (_) { :e },
  '/' => make_dir_func({e: :n,w: :s,n: :e,s: :w}),
  '\\' => make_dir_func({e: :s,w: :n,n: :w,s: :e}),
  'O' => make_dir_func({e: :w,w: :e,n: :s,s: :n}),
}

def next_direction(symbol, direction)
  NEXT_DIR_FUNC_FROM_SYMBOL[symbol].call(direction)
end

def make_step(row, col, direction)
  case direction
    when :e
      col += 1
    when :w
      col -= 1
    when :n
      row -= 1
    when :s
      row += 1
    else
      raise 'Wrong symbol'
  end
  [row, col]
end

class LoopException < Exception
end

def solve
  row, col = laser_pos maze
  direction = :e
  path = []
  while symbol = object_at(row, col)
    direction = next_direction(symbol, direction)
    step = [row, col, direction]
    if path.include? step
      raise LoopException
    end
    path << step
    row, col = make_step(row, col, direction)
  end
  print path.length
rescue LoopException
  print -1
end

solve