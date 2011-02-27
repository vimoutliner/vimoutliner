#!/usr/bin/ruby

# usage:
# calendar_generator.rb <calendar_folder> <years>

# indent for months, days are indented one more level
# both 0 and 1 make sense
MONTHINDENT = 0


# insert _tag_ todo and _tag_ done items under each day
# DIARY = ["Zu erledigen", "Tagebuch", "Abrechnen"]
# DIARY = [] # for empty days.
DIARY = ["To do", "Diary", "Timesheet"] # deluxe edition


# adapt to your preference
# Sunday should be first, Saturday last entry
# DAYNAMES = %w(So Mo Di Mi Do Fr Sa)
DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)


# January should be first, December last entry
# MONTHNAMES = %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
MONTHNAMES = %w(January February March April May June July August September October November December)

# you should not need to change anything below here
# but you are welcome to write equivalent functionality
# in your language of choice.
# ------------------------------------------------------------
require "date"

TAGFORMAT = "%.4d_%.2d_%.2d"


def indent(sublevel)
  "\t"*(MONTHINDENT+sublevel)
end

def month(date)
  MONTHNAMES[date.month - 1] + 
    (MONTHINDENT == 0 ? " " + date.year.to_s : "")
end

class Shelf
  def initialize(path)
    begin
      @shelf = File.readlines(path)
    rescue 
      @shelf = Array.new
    end
    @path = path
  end
  def parse
    unless @books
      @books = Hash.new
      (0...@shelf.size).step(2) do |i|
        @books[@shelf[i].strip] = @shelf[i+1].strip
      end
    end
  end
  def save()
    File.open(@path, "w") do |out|
      @books.sort.each do |key,value|
        out.puts(key)
        out.puts("\t" + value)
      end if @books
    end
  end
  def update(year)
    re = /^_tag_calendar_#{year}/
    unless @shelf.any? { |str| re.match(str) }
      parse
      @books["_tag_calendar_#{year}"] = "#{year}.otl"
      save
    end
  end
end

def update_shelf(year)
  shelf = Shelf.new(CALENDAR + "/vo_calendar_shelf.otl")
  shelf.update(year)
end

CALENDAR = ARGV.shift

ARGV.each do |arg|

  File.open(CALENDAR + "/" + arg + ".otl", "w") do |out|

    update_shelf(arg)
    year = arg.to_i
    d = Date.new(year, 1, 1)
    out.puts year if MONTHINDENT == 1

    while d.year == year
      out.puts indent(0) + month(d)
      month = d.month
      while d.month == month
        out.puts indent(1) + (TAGFORMAT % [d.year, d.month, d.day]) +
          " " + DAYNAMES[d.wday]
        DIARY.each do |item|
          out.puts indent(2) + item
        end
        d += 1
      end
    end

  end
end
