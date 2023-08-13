# frozen_string_literal: true

# require 'random'

# COLORS = :red, :green, :yellow, :blue, :purple, :orange
COLORS = (1..6).to_a.map(&:to_s)
GUESSES = 12
HOLES = 4

# A single row on the Mastermind board
class Row
  attr_accessor :holes
  attr_reader :result

  def initialize
    @holes = [nil] * HOLES
    @result = nil
  end

  def check(code)
    return if @holes[0].nil?

    @result = code_checker @holes, code
  end

  def to_s
    "#{@holes.join('')} => #{@result[:black]}b, #{@result[:white]}w"
  end
end

# A Mastermind board
class Board
  def initialize(code = nil)
    @code = code || random_code
    @rows = []
  end

  def to_s
    (@rows.map(&:to_s).join "\n") + "\n----------------------------------"
  end

  def new_guess(guess)
    @rows.append(Row.new)
    @rows[-1].holes = guess
    @rows[-1].check @code
  end

  def finished?
    return false unless @rows != []
    return 'win' if @rows[-1].result[:black] == HOLES
    return 'lose' if @rows.length == GUESSES

    false
  end

  def last_result
    return nil if @rows == []

    @rows[-1].result
  end
end

def random_code
  ([nil] * HOLES).map { COLORS.sample }
end

def code_checker(code1, code2)
  result = { white: 0, black: 0 }
  COLORS.each { |c| result[:white] += [code1.count(c), code2.count(c)].min }
  code1.each_with_index do |c, i|
    if code2[i] == c
      result[:black] += 1
      result[:white] -= 1
    end
  end
  result
end

def read_code(prompt)
  guess = nil
  loop do
    print("#{prompt}: ")
    guess = gets.chomp
    break if (guess.length == HOLES) && (guess.split('').all? { |c| COLORS.include?(c) })
  end
  guess.split('')
end

def player_guess
  b = Board.new
  until b.finished?
    guess = read_code 'Guess'
    b.new_guess guess
    puts b
  end
  puts "You #{b.finished?}"
end

def player_create
  Board.new(read_code('Secret'))
end

def computer_guess(board)
  all_codes = COLORS.product(*([COLORS] * (HOLES - 1)))
  next_guess = if HOLES == 4 && COLORS.length >= 2
                 %w[1 1 2 2]
               else
                 all_codes.sample
               end

  until board.finished?
    board.new_guess next_guess
    break if board.finished?

    result = board.last_result
    all_codes.select! { |c| code_checker(next_guess, c) == result }
    next_guess = all_codes.sample
    puts board
  end
  puts board
  puts "I #{board.finished?}"
end

# main
puts "Colors: #{COLORS}"
puts "Holes: #{HOLES}"

mode = nil
loop do
  puts '(c)reate or (g)uess? '
  mode = gets.chomp
  break if %w[c g].include?(mode)
end

if mode == 'g'
  player_guess
else
  board = player_create
  computer_guess board
end
