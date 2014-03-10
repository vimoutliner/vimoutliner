#!      /usr/bin/ruby

# = Synopsis
#
# vo2xo: Converts VIM Outliner files to OpenDocument presentations.
#
# = Usage
#
# vo2odp [OPTION] input-file output-file
#
# -?, --help: show help
#
# input-file: The VIM Outliner file to be converted.

# LICENSE
# Copyright (C) 2006 Bruce Perens
#
# You may apply the terms of GPL Version 3 or, at your choice, any later
# version of the GPL published by the Free Software Foundation, Inc. of
# Boston, MA, USA, to this software.
#
# You may not modify this license. You must preserve it and the accompanying
# copyright declaration in any whole or fragmentary verisons of the software
# to which they apply.
#
require 'getoptlong'
require 'rdoc/usage'
require 'rubygems'
require_gem 'builder'
require_gem 'rubyzip'
require 'zip/zipfilesystem'

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

module OpenDocument
end
module OpenDocument::Presentation
private
  DocumentAttributes = {
    :'office:version' => '1.0',
    :'xmlns:anim' => 'urn:oasis:names:tc:opendocument:xmlns:animation:1.0',
    :'xmlns:chart' => 'urn:oasis:names:tc:opendocument:xmlns:chart:1.0',
    :'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
    :'xmlns:dom' => 'http://www.w3.org/2001/xml-events',
    :'xmlns:dr3d' => 'urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0',
    :'xmlns:draw' => 'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
    :'xmlns:fo' => 'urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0',
    :'xmlns:form' => 'urn:oasis:names:tc:opendocument:xmlns:form:1.0',
    :'xmlns:math' => 'http://www.w3.org/1998/Math/MathML',
    :'xmlns:meta' => 'urn:oasis:names:tc:opendocument:xmlns:meta:1.0',
    :'xmlns:number' => 'urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0',
    :'xmlns:office' => 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
    :'xmlns:ooo' => 'http://openoffice.org/2004/office',
    :'xmlns:oooc' => 'http://openoffice.org/2004/calc',
    :'xmlns:ooow' => 'http://openoffice.org/2004/writer',
    :'xmlns:presentation' => 'urn:oasis:names:tc:opendocument:xmlns:presentation:1.0',
    :'xmlns:script' => 'urn:oasis:names:tc:opendocument:xmlns:script:1.0',
    :'xmlns:smil' => 'urn:oasis:names:tc:opendocument:xmlns:smil-compatible:1.0',
    :'xmlns:style' => 'urn:oasis:names:tc:opendocument:xmlns:style:1.0',
    :'xmlns:svg' => 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0',
    :'xmlns:table' => 'urn:oasis:names:tc:opendocument:xmlns:table:1.0',
    :'xmlns:text' => 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
    :'xmlns:xforms' => 'http://www.w3.org/2002/xforms',
    :'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
    :'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
    :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  }.freeze
  
  
  # Bullet style for a particular indentation level.
  def bullet_style(x, level, char, space_before, label_width, font_size)
    x.tag!('text:list-level-style-bullet', :'text:level' => level,
    :'text:bullet-char' => char) {
      if level > 1
        x.tag!('style:list-level-properties',
        :'text:space-before' => space_before,
        :'text:min-label-width' => label_width)
      end
      x.tag!('style:text-properties', :'fo:font-family' => 'StarSymbol',
      :'style:use-window-font-color' => 'true', :'fo:font-size' => font_size)
    }
  end
  
  # Paragraph style for a particular level.
  def paragraph_style(x, name, left_margin, text_indent)
    x.tag!('style:style', :'style:name' => name,
    :'style:family' => 'paragraph') {
      x.tag!('style:paragraph-properties', :'fo:margin-left' => left_margin,
      :'fo:margin-right' => '0cm', :'fo:text-indent' => text_indent)
  
    }
  end
  
  # Presentation style.
  def presentation_style(x, name, parent, min_font_height, additional = {})
    x.tag!('style:style', :'style:name' => name,
    :'style:family' => 'presentation',
    :'style:parent-style-name' => parent) {
      x.tag!('style:graphic-properties', {:'draw:fill-color' => '#ffffff',
      :'fo:min-height' => min_font_height}.merge(additional))
    }
  end

  # OpenOffice automatic styles.
  # I started with a normal output file of OpenOffice, and attempted to compress
  # the information: not for efficiency, but to make it understandable. The
  # output should be close to identical.
  #
  def automatic_styles(x)
    x.tag!('office:automatic-styles') {
  
      shared = { :'presentation:display-footer' => 'true',
       :'presentation:display-page-number' => 'false',
       :'presentation:display-date-time' => 'true' }
  
      x.tag!('style:style', :'style:name' => 'dp1', :'style:family' => 'drawing-page') {
        x.tag!('style:drawing-page-properties', 
         { :'presentation:background-visible' => 'true',
         :'presentation:background-objects-visible' => 'true' }.merge(shared))
      }
      x.tag!('style:style', :'style:name' => 'dp2', :'style:family' => 'drawing-page') {
        x.tag!('style:drawing-page-properties', 
         { :'presentation:display-header' => 'true' }.merge(shared))
      }
  
      x.tag!('style:style', :'style:name' => 'gr1', :'style:family' => 'graphic') {
        x.tag!('style:graphic-properties', :'style:protect' => 'size')
      }
  
      presentation_style(x, 'pr1', 'Default-title', '3.256cm')
      presentation_style(x, 'pr2', 'Default-outline1', '13.609cm')
      presentation_style(x, 'pr3', 'Default-notes', '12.573cm',
      :'draw:auto-grow-height' => 'true')
  
      paragraph_style(x, 'P1', '0cm', '0cm')
      paragraph_style(x, 'P2', '1.2cm', '-0.9cm')
      paragraph_style(x, 'P3', '0.6cm', '-0.6cm')
  
      x.tag!('text:list-style', :'style:name' => 'L1') {
        1.upto(9) { |n|
          bullet_style(x, n, :'&#226;&#8212;', "#{(n - 1) * 0.6}cm", '0.6cm',
	  '45%')
        }
      }
      x.tag!('text:list-style', :'style:name' => 'L2') {
        bullet_style(x, 1, :'&#226;&#8212;',        '0.6cm', '0.9cm', '45%')
        bullet_style(x, 2, :'&#226;&#8364;&#8220;', '1.6cm', '0.8cm', '75%')
        bullet_style(x, 3, :'&#226;&#8212;',        '3.0cm', '0.6cm', '45%')
        bullet_style(x, 4, :'&#226;&#8364;&#8220;', '4.2cm', '0.6cm', '75%')
        bullet_style(x, 5, :'&#226;&#8212;',        '5.4cm', '0.6cm', '45%')
        bullet_style(x, 6, :'&#226;&#8212;',        '6.6cm', '0.6cm', '45%')
        bullet_style(x, 7, :'&#226;&#8212;',        '7.8cm', '0.6cm', '45%')
        bullet_style(x, 8, :'&#226;&#8212;',        '9.0cm', '0.6cm', '45%')
        bullet_style(x, 9, :'&#226;&#8212;',       '10.2cm', '0.6cm', '45%')
      }
    }
  end

public
  def wrap(x)
    x.instruct!
    x.tag!('office:document-content', DocumentAttributes) {
      automatic_styles(x)
      x.tag!('office:body') {
        x.tag!('office:presentation') {
          yield(x)
	}
      }
    }
    x
  end
end

class OpenDocument::Manifest
public
  def add(path, type)
    @files[path] = type
  end

  def content
    x = Builder::XmlMarkup.new(:indent => 2)
    x.instruct!
    x.tag!('manifest:manifest',
    :'xmlns:manifest' => 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0') {
      x.tag!('manifest:file-entry',
      :'manifest:media-type' => \
      'application/vnd.oasis.opendocument.presentation',
      :'manifest:full-path' => '/')
      @files.each { |k, v|
        x.tag!('manifest:file-entry', :'manifest:media-type' => v,
	:'manifest:full-path' => k)
      }
    }
    x.target!
  end

  def initialize
    @files = {}
  end
end

class OutlineToODP < OutlineParser
  include OpenDocument::Presentation

protected
  def nest_headings(text, nesting, recurse)
    @x.tag!('text:list-item') {
      if recurse == 0
        @x.tag!('text:p', :'text:style-name' => "P#{nesting + 1}") {
  	  @x << text
	  @x << "\n"
        }
      else
        @x.tag!('text:list') { nest_headings(text, nesting, recurse - 1) }
      end
    }
  end

  def heading(text, nesting)
   if nesting == 0
    @x.tag!('draw:page', :'draw:name' => text, :'draw:style-name' => 'dp1',
    :'draw:master-page-name' => 'Default',
    :'presentation:presentation-page-layout-name' => 'AL1T2') {
      @x.tag!('draw:frame', :'presentation:style-name' => 'pr1',
      :'draw:layer' => 'layout', :'svg:width' => '25.199cm',
      :'svg:height' => '3.256cm', :'svg:x' => '1.4cm', :'svg:y' => '0.962cm',
      :'presentation:class' => 'title', :'presentation:placeholder' => true) {
        @x.tag!('draw:text-box') {
          @x.tag!('text:p', :'text:style-name' => 'P1') {
	    @x << text
	    @x << "\n"
	  }
        }
      }
      @x.tag!('draw:frame', :'presentation:style-name' => 'pr2',
      :'draw:layer' => 'layout', :'svg:width' => '25.199cm',
      :'svg:height' => '13.609cm', :'svg:x' => '1.4cm', :'svg:y' => '4.914cm',
      :'presentation:class' => 'outline', :'presentation:placeholder' => true) {
        @x.tag!('draw:text-box') {
	  parse(true)
        }
      }
    }
   else
     @x.tag!('text:list', :'text:style-name' => 'L2') {
       nest_headings(text, nesting, nesting - 1)
     }
   end
  end

  def nest(nesting)
    parse(true)
  end

  def text(t, nesting)
  end

public
  def initialize(input_file)
    super(input_file)
  end

  def convert
    @x = Builder::XmlMarkup.new(:indent => 2)
    wrap(@x) {
      while more
        parse(false)
      end
    }
    @x.target!
  end
end


opts = GetoptLong.new(
  [ '--help', '-?', GetoptLong::NO_ARGUMENT ]
)

begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        RDoc::usage
    end
  end
  
  if ARGV.length != 2
    RDoc::usage
    exit 0
  end

  input_file = File.new(ARGV[0], 'r')
  output_file = Zip::ZipFile.open(ARGV[1], Zip::ZipFile::CREATE)
rescue Exception => error
  $stderr.print("Error: #{error}\n")
  exit(1)
end

c = OutlineToODP.new(input_file)
if not c.more
  $stderr.write("Error: Input file contains no content.\n")
  exit(1)
end

  manifest = OpenDocument::Manifest.new
  output_file.file.open('content.xml', 'w') { |f| f.write(c.convert) }
  manifest.add('content.xml', 'text/xml')
  output_file.dir.mkdir('META-INF')
  output_file.file.open('META-INF/manifest.xml', 'w') { |f|
    f.write(manifest.content)
  }
  output_file.close
exit(0)
