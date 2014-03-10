#!      /usr/bin/ruby

# = Synopsis
#
# vo2xo: Converts VIM Outliner files to Xoxo presentations.
#
# = Usage
#
# vo2xo [OPTION] input-file
#
# -?, --help: show help
#
# -b, --body file-name:
#   insert the contents of the named file at the start of the HTML BODY element.
#
# -h, --head file-name:
#   insert the contents of the named file within the HTML HEAD element.    
#
# input-file: The VIM Outliner file to be converted.

# LICENSE
# Copyright (C) 2006 Bruce Perens
#
# This license incorporates by reference the terms of GPL Version 3 or, at
# your choice, any later version of the GPL published by the Free Software
# Foundation, Inc. of Boston, MA, USA.
#
# You may not modify this license. You must preserve it and the accompanying
# copyright declaration in any whole or fragmentary verisons of the software
# to which they apply.
#
require 'getoptlong'
require 'rdoc/usage'
require 'rubygems'
require_gem 'builder'

class OutlineParser
private
  LeadingTabPattern = /^(\t*)(.*)$/.freeze
  ColonPattern = /^:[ \t]*(.*)$/.freeze

protected
  def initialize(file)
    @file = file
    @pushback = nil
    @nesting = 0
  end

  # Get a line, with push-back.
  def get_line
    if (line = @pushback)
      @pushback = nil
      return line 
    else
      return @file.gets
    end
  end

  # Recursive parser for VIM Outliner.
  #
  # Meant to be called from itself when nesting increases - it calls its
  # callers "nest" method, which calls "parse". This fits well with nesting
  # output paradigms like that of Builder::XmlMarkup.
  #
  # Returns when nesting decreases, or if got_heading is set, just before the
  # next top-level heading in the input stream. You should iteratively call
  # parse() until more() returns false. This facilitates per-heading handling
  # such as in the Xoxo converter, which uses first-level heading to demarcate
  # the boundaries of slides.
  #
  #  got_heading: If set, this will return just before the next top-level
  #    heading, leaving it in the push-back.
  #
  def parse(got_heading = false)

    while (line = get_line())
      m = line.match(LeadingTabPattern)
      n = m[1].length   # This line's nesting level.
      after_tabs = m[2]	# Content after zero or more leading tabs.

      # Drop empty lines, and lines with only tabs.
      next if after_tabs == ''

      if n != @nesting # The nesting level changes with this line.
        previous = @nesting
        @nesting = n
        @pushback = line

        # If nesting increases, recursively parse it through nest().
	# If nesting decreases, return to nest(), which will in turn
	# return here. Both of these can be true in sequence! Nest()
	# detects when a nesting level is closed by looking ahead one
	# line and then pushing it back. That line can be one or MORE
	# levels lesser than the current nesting level.
	#
        nest(n) if n > previous
        return true if n < previous
      elsif
        if (p = after_tabs.match(ColonPattern)) and p[1].length > 0
          text(p[1], n)
        else
	    if got_heading and n == 0
            @pushback = line
            return true # Return before the next top-level heading.
	    end

	    got_heading = true
          heading(after_tabs, n)
        end
      end
    end
    false
  end

public
  # Simple parser that return true if there is any remaining content
  # and leaves that content in the push-back.
  # The return value is the content minus any leading tabs.
  #
  # Usage
  # 	Return true if there is more content:
  # 		if more
  # 	Return the content of the next line to be read.
  # 		more
  #
  # The second form is used to get the document title from the first line
  # in the file.
  #
  def more
    while (line = get_line())
      if (m = line.match(LeadingTabPattern)) and m[2].length > 0
        @pushback = line
	return m[2]
      end
    end
    false
  end

end

class OutlineToXoxo < OutlineParser
private
    Type = [ :DOCTYPE,
             :html,
	     :PUBLIC,
	     '-//W3C//DTD XHTML 1.0 Strict//EN',
	     'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
	   ].freeze


protected
  def heading(text, nesting)
   if nesting == 0
     @x.h1(text)
   else
     @x.li { @x.tag!("h#{nesting + 1}", text) }
   end
  end

  def nest(nesting)
    if nesting == 1
      @x.ul { parse(true) }
    else
      @x.li(:class => 'nesting') { @x.ul { parse(true) } }
    end
  end

  def text(t, nesting)
   @x.p(t)
  end

public
  def initialize(input_file, head_insert, body_insert)
    @head_insert = head_insert
    @body_insert = body_insert
    super(input_file)
  end

  def convert
    @x = Builder::XmlMarkup.new(:indent => 2)
    @x.declare!(*Type)
    @x.html {
      @x.head {
        @x.title(more)
	@x << @head_insert.read if @head_insert
      }
      @x.body {
	@x << @body_insert.read if @body_insert
        @x.ul {
          @x.li(:class => "slide") { parse(false) } while more
        }
      }
    }
    @x.target!
  end

end


opts = GetoptLong.new(
  [ '--help', '-?', GetoptLong::NO_ARGUMENT ],
  [ '--body', '-b', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--head', '-h', GetoptLong::REQUIRED_ARGUMENT ]
)

body_insert = nil
head_insert = nil

begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        RDoc::usage
      when '--body'
        body_insert = File.new(arg, 'r')
      when '--head'
        head_insert = File.new(arg, 'r')
    end
  end
  
  if ARGV.length != 1
    RDoc::usage
    exit 0
  end

  input_file = File.new(ARGV[0], 'r')
rescue Exception => error
  $stderr.print("Error: #{error}\n")
  exit(1)
end

c = OutlineToXoxo.new(input_file, head_insert, body_insert)
if not c.more
  $stderr.write("Error: Input file contains no content.\n")
  exit(1)
end

$stdout.write(c.convert)
exit(0)
