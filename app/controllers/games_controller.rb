require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    # here I want to generate an array of random 10 letters
    vowel = ["A", "E", "I", "O", "U", "Y"].to_a.shuffle
    second_array = ("A".."Z").to_a.sample(vowel.count)

    @grid = (second_array + vowel).last(10) # array of all consonants

    @start_time = Time.now
  end

  def score
    # get the start time and end time
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @time_taken = end_time - start_time

    # prepare my result message
    @result = { score: 0, message: '', time: "#{@time_taken.round(2)} sec" }

    # Retrieve grid value from hidden field tag
    @grid = params[:grid].split(",")

    # check if word is in the dict
    @answer = params[:answer]
    url = "https://wagon-dictionary.herokuapp.com/#{@answer}"
    user_serialized = URI.open(url).read
    @user = JSON.parse(user_serialized) # example > bob {"found"=>true, "word"=>"bob", "length"=>3}

    # clean the grid
    @clean_grid = @grid.join.downcase.chars
    @word = @user['word'].chars

    if @word.all? { |letter| @clean_grid.count(letter) >= @word.count(letter)} && @user["found"] == true
      @result[:score] = @user['length'] / (@time_taken / 10)
      @result[:score] = @result[:score].round(2)
      @result[:message] = "Well done! You've found... '#{@answer}'"
    elsif @user["found"] != true
      @result[:score] = 0
      @result[:message] = 'not an english word'
    else
      @result[:score] = 0
      @result[:message] = 'not in the grid'
    end
  end
end
