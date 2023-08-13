SIZE = 3

class Player
  def initialize symbol, board
    @symbol = symbol
    @board = board
  end
  
  def symbol
    @symbol
  end
  
  def move
    loop do
      puts @board
      puts "Row? (1..#{SIZE})"
      row = gets.to_i
      puts "Column? (1..#{SIZE})"
      col = gets.to_i
      break if @board.put row, col, @symbol
      puts "Falsche Einabe oder Feld nicht frei"
    end
    w = @board.check
    puts "I won!" if w == @symbol
  end
end

class Board
  def initialize
    @state = (1..SIZE).reduce([]) do |rresult, row|
      rresult.append((1..SIZE).reduce([]) do |result, col|
                       result.append(" ")
                       result
                     end
                    )
      rresult
    end
    @winner = nil
    @free = SIZE * SIZE
  end

  def to_s
    rows = @state.reduce([]) { |rresult, row| rresult.append(row.join"|") }
    rows.join("\n" + "-+" * (SIZE - 1) + "-\n")
  end

  def put row, col, symbol
    return false if row < 1 or col < 1 or row > SIZE or col > SIZE
    return false if @state[row - 1][col - 1] != " "
    @state[row - 1][col - 1] = symbol
    @free -= 1
    true
  end

  def check
    check_row (0...SIZE).map{ |x| @state[x][x] } and return @winner
    check_row (0...SIZE).map{ |x| @state[x][SIZE - 1 - x] } and return @winner
    (0...SIZE).each do |row|
      check_row (0...SIZE).map{ |x| @state[row][x] } and return @winner
    end
    (0...SIZE).each do |col|
      check_row (0...SIZE).map{ |x| @state[x][col] } and return @winner
    end
    nil
  end

  def winner
    @winner
  end

  def free
    @free > 0
  end
  
  private
  def check_row row
    s = row.sort.uniq
    if s.length == 1 and s[0] != " "
      @winner = s[0]
      return true
    end
    false
  end
end

class Game
  def initialize
    @board = Board.new
    @p1 = Player.new "X", @board
    @p2 = Player.new "O", @board
  end

  def run    
    loop do
      puts "\nPlayer 1\n"
      @p1.move
      break if @board.winner or not @board.free
      puts "\nPlayer 2\n"
      @p2.move
      break if @board.winner or not @board.free
    end
    puts "Draw" unless @board.winner
    puts @board
  end
end
