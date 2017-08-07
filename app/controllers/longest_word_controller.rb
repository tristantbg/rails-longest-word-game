require 'open-uri'
require 'json'

class LongestWordController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @grid = params[:grid].chars
    @start_time = Time.parse(params[:start_time])
    @attempt = params[:attempt]
    @result = run_game(@attempt, @grid, @start_time, Time.now)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ("A".."Z").to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    if word_in_grid?(attempt, grid) && word_exists?(attempt)
      get_score(attempt, grid, start_time, end_time)
    else
      time = end_time - start_time
      if !word_exists?(attempt)
        { status: "error", time: time, score: 0, message: "Your word is not an english word." }
      elsif !word_in_grid?(attempt, grid)
        { status: "error", time: time, score: 0, message: "Your word is not in the grid." }
      end
    end
  end

  def word_exists?(word)
    url = "https://wagon-dictionary.herokuapp.com/" + word
    response = open(url).read
    results = JSON.parse(response)
    results["found"]
  end

  def word_in_grid?(attempt, grid)
    tmp_array = attempt.upcase.chars
    @grid.each do |e|
      i = tmp_array.index(e)
      tmp_array.delete_at(i) if i
    end
    tmp_array.empty?
  end

  def get_score(attempt, grid, start_time, end_time)
    constant = 4
    time = end_time - start_time
    score = ((1 + attempt.length.fdiv(grid.length) * attempt.length) / time.to_f) * constant * 1000
    { status: "OK", time: time, score: score.to_i, message: "Well done!" }
  end
end
