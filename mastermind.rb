#require 'random'

#COLORS = :red, :green, :yellow, :blue, :purple, :orange
COLORS = (1..6).to_a.map(&:to_s)
GUESSES = 12
HOLES = 4

class Row
    def initialize
        @holes = [nil] * HOLES
        @result = nil
    end

    def check code
        if @holes[0] != nil
            @result = code_checker @holes, code
        end
    end

    def holes= h
        @holes = h
    end

    def holes
        @holes
    end

    def result
        @result
    end

    def to_s
        "#{@holes.join('')} => #{@result[:black]}b, #{@result[:white]}w"
    end
end

class Board
    def initialize code=nil
        @code = code ? code : random_code
        @rows = []
    end
    
    def to_s
        result = (@rows.map(&:to_s).join "\n") + "\n----------------------------------"
    end

    def new_guess guess
        @rows.append(Row.new)
        @rows[-1].holes= guess
        @rows[-1].check @code     
    end

    def finished?
        return false unless @rows != []
        return "win" if @rows[-1].result[:black] == HOLES
        return "lose" if @rows.length == GUESSES
        return false
    end

    def last_result
        return nil if @rows == []
        return @rows[-1].result
    end
end

def random_code
    ([nil] * HOLES).map {COLORS.sample}
end

def code_checker code1, code2
    result = {white: 0, black: 0}
    COLORS.each do |c|
        result[:white] += [code1.count(c), code2.count(c)].min
    end
    code1.each_with_index do |c, i|
        if code2[i] == c then
            result[:black] += 1
            result[:white] -= 1
        end
    end
    result
end

def read_code prompt
    begin
        print("#{prompt}: ")
        guess = gets.chomp
    end until (guess.length == HOLES) and (guess.split("").all? { |c| COLORS.include?(c) })
    guess.split("")
end

def player_guess
    b = Board.new
    until b.finished?
        guess = read_code "Guess"
        b.new_guess guess
        puts b
    end
    puts "You #{b.finished?}"
end

def player_create
    b = Board.new (read_code "Secret")
end

def computer_guess board
    all_codes = COLORS.product(*([COLORS]*(HOLES - 1)))
    if HOLES == 4 and COLORS.length >= 2
        next_guess = ['1', '1', '2', '2']
    else
        next_guess = all_codes.sample
    end

    until board.finished?
        board.new_guess next_guess
        break if board.finished?
        result = board.last_result
        all_codes.reject! { |c| code_checker(next_guess, c) != result}
        next_guess = all_codes.sample
        puts board
    end
    puts board
    puts "I #{board.finished?}"
end

# main
puts "Colors: #{COLORS}"
puts "Holes: #{HOLES}"

begin
    puts "(c)reate or (g)uess? "
    mode = gets.chomp
end until ['c', 'g'].include?(mode)

if mode == 'g'
    player_guess
else
    board = player_create
    computer_guess board
end
