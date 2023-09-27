# frozen_string_literal: true
require 'yaml'

# Game Class
class Game
  def initialize
    @secret_word = set_secret_word
    @guessed_word = Array.new(@secret_word.length) { '-' }
    @guess_count = 0
    @letters_guessed = []
    @won = false
    @loss = false
  end

  def start
    puts 'Do you want to play the Hangman game', 'Press [1] to start a new game', 'press [2] to load a saved game'

    user_input = gets.chomp.to_i

    if user_input == 1
      game_loop
    else
      load_game
    end
  end

  def game_loop
    loop do
      make_guess

      if @loss
        puts
        puts 'Game over, you lose'
        puts "secret word: #{@secret_word}"
        break
      end

      if @won
        puts
        puts 'you won'
        break
      end

      break if @saved
    end
  end

  private

  def save_game
    # Serialize the game state and save it to a file.
    game_data = {
      secret_word: @secret_word,
      guessed_word: @guessed_word,
      guess_count: @guess_count,
      letters_guessed: @letters_guessed,
      won: @won,
      loss: @loss,
      guess: @guess
    }

    puts
    puts 'enter filename'
    filename = gets.chomp.downcase

    File.open("saved/#{filename}.yaml", 'w') do |file|
      file.puts YAML.dump(game_data)
    end

    puts "Game saved to #{filename}"
    @saved = true
  end

  def load_game
    # Deserialize a saved game state and return a new Game instance.
    saved_game_files = Dir.glob('saved/*')

    if saved_game_files.empty?
      puts 'No saved games found'
      return nil
    end

    puts
    puts 'Select a saved game to load'
    saved_game_files.each_with_index do |file, index|
      puts "#{index + 1}. #{File.basename(file)}"
    end

    puts 'Enter the name of the saved game to load it'
    choice = gets.chomp.to_i

    if choice.between?(1, saved_game_files.length)
      filename = saved_game_files[choice - 1]
      game_data = YAML.load_file(filename)

      game = Game.new
      game.instance_variable_set(:@secret_word, game_data[:secret_word])
      game.instance_variable_set(:@guessed_word, game_data[:guessed_word])
      game.instance_variable_set(:@guess_count, game_data[:guess_count])
      game.instance_variable_set(:@letters_guessed, game_data[:letters_guessed])
      game.instance_variable_set(:@won, game_data[:won])
      game.instance_variable_set(:@loss, game_data[:loss])
      game.instance_variable_set(:@guess, game_data[:guess])

      puts "Game loaded from #{filename}"
      game.game_loop
    else
      puts 'Invalid choice. No game loaded.'
    end
  end

  def make_guess
    puts
    puts @guessed_word.join
    puts 'Enter a letter, or type save to save progress: '
    @guess = gets.chomp.downcase

    if @guess == 'save'
      save_game
      return
    end

    @letters_guessed << @guess unless @letters_guessed.include?(@guess)

    correct_guess = [false]

    @secret_word.split('').each_with_index do |letter, index|
      if letter == @guess
        @guessed_word[index] = @guess
        correct_guess[0] = true
      end
      p "letter: #{letter} --- guess: #{@guess}"
    end

    puts

    if correct_guess[0] == true
      puts 'Good Guess'
      puts "Letter guessed: #{@letters_guessed.join(' ')}"
    else
      puts 'No Luck!'
      puts "Letter guessed: #{@letters_guessed.join(' ')}"
      @guess_count += 1
    end

    display_game_state
    check_win
    check_loss
  end

  def set_secret_word
    words_array = []

    File.foreach('google-10000-english-no-swears.txt') do |word|
      word.chomp!
      words_array << word if word.length.between?(5, 12)
    end

    words_array[rand 0..(words_array.length - 1)].downcase
  end

  def display_game_state
    puts "Incorrect guesses remaining: #{10 - @guess_count}"
  end

  def check_win
    @won = true if @secret_word == @guessed_word.join
  end

  def check_loss
    @loss = true if @guess_count == 10
  end
end
