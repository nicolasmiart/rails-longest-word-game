class GamesController < ApplicationController
  require 'open-uri'
  require 'json'

  def new
    @letters = Array.new(10) { ("A".."Z").to_a.sample }
    @start_time = Time.now
    session[:letters] = @letters
    session[:start_time] = @start_time
  end

  def score
    end_time = Time.now
    start_time = session[:start_time]
    start_time = Time.zone.parse(start_time)
    @result = { score: 0.to_f, time: (end_time - start_time).to_f }
    @letters = session[:letters]
    attempt = params[:word]
    if english?(attempt) == false
      @result[:message] = "Sorry but #{attempt.upcase} doesn't seem to be a valid English word..."
    elsif letters_included_in_grid?(attempt.upcase, @letters) == false
      @result[:message] = "Sorry but #{attempt.upcase} can't be build out of #{@letters.join(', ')}"
    else
      @result[:score] = (attempt.length * attempt.length).to_f / (end_time - start_time)
      @result[:message] = "<strong>Congratulation!</strong> #{attempt.upcase} is a valid English word!".html_safe
    end
  end

  def english?(word)
    if word.match?(/\A[a-zA-Z]+\z/)
      url = "https://dictionary.lewagon.com/#{word.downcase}"
      word_check_serialized = URI.parse(url).read
      checked_word = JSON.parse(word_check_serialized)
      return checked_word["found"]
    else
      return false
    end
  end

  def letters_included_in_grid?(attempt, grid)
    # attempt is string, grid is array
    attempt_letters = attempt.chars
    attempt_letters = attempt_letters.tally
    grid = grid.tally
    p attempt_letters
    p grid
    attempt_letters.all? do |letter, frequency|
      grid[letter].to_i >= frequency
    end
  end
end
