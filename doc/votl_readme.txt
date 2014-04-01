*votl_readme.txt*	For Vim version 7.2	Last change: 2013-04-10

                                                                *vo* *vimoutliner*
VimOutliner  0.3.7 ~

VimOutliner is an outline processor designed with lighting fast authoring as
the main feature, it also has many of the same features as Grandview, More,
Thinktank, Ecco, etc. These features include tree expand/collapse, tree
promotion/demotion, level sensitive colors, interoutline linking, checkboxes
and body text.


  License                                                         |votl-license|
  Version                                                         |votl-version|
  Installing and testing VimOutliner                              |votl-install|
      Automatic method                                       |votl-auto-install|
      Updating                                                   |votl-updating|
      Manual method                                        |votl-manual-install|
      Testing                                                     |votl-testing|
      Installation from distribution packages                    |votl-packages|


  Using VimOutliner on other file types                       |votl-other-files|
  Troubleshooting                                         |votl-troubleshooting|
  VimOutliner philosophy                                       |votl-philosophy|
  Running VimOutliner                                             |votl-running|
      Comma comma commands                                        |votl-command|
      Basic VimOutliner activities                             |votl-activities|
      Menu                                                           |votl-menu|
      Vim Outliner objects                                        |votl-objects|
      Post Processors                                     |votl-post-processors|
  Advanced                                                       |votl-advanced|
      Executable Lines                                   |votl-executable-lines|
  Plugins                                                         |votl-plugins|
      Checkboxes                                                 |votl-checkbox|
      Hoisting                                                   |votl-hoisting|
      Clock                                                       |vo-clock|
  Scripts                                                         |votl-scripts|
      votl_maketags.pl                                           |votl-maketags|
      otl2html.py                                                     |otl2html|
  Other information                                            |votl-other-info|


==============================================================================
License                                                           *votl-license*


VimOutliner Copyright (C) 2001, 2003 by Steve Litt
            Copyright (C) 2004 by Noel Henson
Licensed under the GNU General Public License (GPL), version 2
Absolutely no warranty, see COPYING file for details.

    HTML: http://www.gnu.org/copyleft/gpl.html
    Text: http://www.gnu.org/copyleft/gpl.txt


==============================================================================
Installing and Testing VimOutliner                                *votl-install*


    Automatic Method                |votl-auto-install|
    Updating                        |votl-updating|
    Manual Method                   |votl-manual-install|
    Testing                         |votl-testing|


                                                             *votl-auto-install*
Automatic Method~

The automatic installation targets Unix-compatible platforms: >

From tar archive

    $ tar xzvf vimoutliner-0.3.x.tar.gz
    $ cd vimoutliner
    $ sh install.sh

From zip archive 

    $ unzip vimoutliner-0.3.x.zip
    $ cd vimoutliner-0.3.x
    $ sh install.sh 

From vimball

Open vimoutliner-0.3.x.vba with Vim and type the following command to install
in your home vim folder:

:so % 

<
The install.sh script will ask you whether to install the VimOutliner files or
abort the process leaving everything unchanged.  Assuming you confirmed the
installation, the script creates the necessary directory tree and copies the
files which provide the core functionality and documentation.

With the second question you decide whether you want to install some brand new
add-ons, currently implementing hoisting and checkboxes.

                                                                 *votl-updating*
Updating~

Updating an existing installation might require some manual work.

If you are already working with a previous VimOutliner release, there is a
slight chance that the current directory tree is different from your current
one. In this case, you will have to manually migrate your files to the new
locations.

The installation script creates unique backups of files being replaced with
newer versions. So if you put some local customisations into, say
$HOME/.vim/vimoutliner/vimoutlinerrc, you'll probably have to merge the backup
with the new file by hand.

                                                           *votl-manual-install*
Manual Method~

You can also copy the files from the unpacked distribution tarball into their
destination folders by yourself. The following steps are a description of what
has to go where and assume some knowledge of your vim setup.

If you encounter problems, please contact the mailinglist for an immediate
solution and more complete future documentation. 
https://groups.google.com/forum/#!forum/vimoutliner

If you want to setup VimOutliner on a system running Microsoft Windows, the
directory $HOME denotes the base folder of the vim installation.  If you're on
Unix based system, the location of $HOME is as usual.

You need the following subtrees in your $HOME directory: >

    $HOME/.vim/
        doc/
        ftdetect/
        ftplugin/
        syntax/
        vimoutliner/
            plugins/
            scripts/
<
The distribution tarball unpacks into a directory vimoutliner with the
following contents: >

    vimoutliner/
        plugins/             (1)
        scripts/             (1)
    doc/                     (1)
    ftdetect/                (1)
    ftplugin/                (1)
    install.sh*
    syntax/                  (1)
    syntax/                  (1)
    vimoutlinerrc            (1)
<
(1) The content of these folders should be copied to their namesakes in the
$HOME/.vim folder

Your $HOME/.vimrc file should contain the lines >

     filetype plugin indent on
     syntax on
<
Finally, you need to integrate the online help provided with VimOutliner into
the vim help system.  Start vim and execute the following command: >
>
    :helptags $HOME/.vim/doc
<
At this point, VimOutliner should be functional.  Type ":help vo" to get
started. You can also type ":help votl_cheatsheet" to a get a quick overview
of all the VimOutliner commands.

                                                                    *votl-testing*
Testing Base Functionality~

Open a new outline with the following:
>
    rm $HOME/votl_test.otl
    gvim $HOME/votl_test.otl or vim $HOME/votl_test.otl
<
Verify the following:
- Tabs indent the text
- Different indent levels are different colors
- Lines starting with a colon and space word-wrap

  Lines starting with colons are body text. They should word wrap and
  should be a special color (typically green, but it can vary). Verify
  that paragraphs of body text can be reformatted with the Vim gq
  commands.

Verify Interoutline Linking:

Interoutline linking currently requires a working perl installation to
generate the necessary tag file. We are looking into porting this to vim's own
scripting language.

Place the following two lines in $HOME/votl_test.otl:
>
    _tag_newfile
        $HOME/votl_newfile.otl
<
Note that in the preceding, the 2nd line should be indented from the first.

To create VimOutliner's tag file $HOME/.vim/vimoutliner/votl_tags.tag, run
votl_maketags.pl, which resides in $HOME/.vimoutliner/scripts/: $
$HOME/.vim/vimoutliner/scripts/votl_maketags.pl $HOME/votl_test.otl

Try the following:
- In $HOME/votl_test.otl
- Cursor to the _tag_newfile marker
- Press CTRL-K
    You should be brought to $HOME/votl_newfile.otl
- Press CTRL-N
    You should be brought back to $HOME/votl_test.otl
Note:
    CTRL-K is a VimOutliner synonym for CTRL-]
    CTRL-N is a VimOutliner synonym for CTRL-T

This might also be achieved more efficiently by using the UTL plugin for
linking to other files and text. Check out the plugin at:

http://www.vim.org/scripts/script.php?script_id=293

                                                      *votl-packages* *votl-debian*
Installation from distribution packages~

Debian and Fedora/Extras include Vim Outliner as a package. It is usually
preferable to use official package custom-tailored for your distribution than
to install VimOutliner from generic tarball.
 

==============================================================================
                                                               *votl-other-files*

How to use VimOutliner on non .otl files~

Previous VimOutliner versions used the ol script to invoke VimOutliner. As of
VimOutliner 0.3.0, the ol script is no longer necessary nor provided. Instead,
VimOutliner is now a Vim plugin, so Vim does all the work.

This makes VimOutliner much simpler to use in most cases, but Vim plugins are
file extension based, meaning that if you want to use VimOutliner on a file
extension other than .otl, you must declare that file extension in
$HOME/.vim/ftdetect/votl.vim. In this section we'll use the .emdl extension
(Easy Menu Definition Language) as an example.

To enable VimOutliner work with .emdl files, do this:
>
    vim $HOME/.vim/ftdetect/votl.vim
<
Right below the line reading:
>
    au! BufRead,BufNewFile *.otl    setfiletype votl
<
Insert the following line:
>
    au! BufRead,BufNewFile *.emdl   setfiletype votl
<
Save and exit
>
    gvim $HOME/votl_test.emdl
<
You should get:
- level colors,
- body text (lines starting with colon)
- comma comma commands (try ,,2 and ,,1)


==============================================================================
Troubleshooting~                                             *votl-troubleshooting*


Q: I can't switch between colon based and space based body text.
A: See next question

Q: My ,,b and ,,B don't do anything. How do I fix it?
A: Open vim like this:
>
      vim $HOME/.vim/ftplugin/votl.vim
<
   Search for use_space_colon
   Make sure it is set to 0, not 1
   Rerun Vim, and ,,b and ,,B should work

Q: I don't get VimOutliner features on files of extension .whatever.
A: Open vim like this:
>
      vim $HOME/.vim/ftdetect/votl.vim
<
   Right below the line reading:
>
      au! BufRead,BufNewFile *.otl          setfiletype votl
<
   Insert the following line:
>
      au! BufRead,BufNewFile *.whatever     setfiletype votl
<
   Save and exit.


==============================================================================
VimOutliner Philosophy~                                           *votl-philosophy*


Authoring Speed~

VimOutliner is an outline processor with many of the same features as
Grandview, More, Thinktank, Ecco, etc. Features include tree expand/collapse,
tree promotion/demotion, level sensitive colors, interoutline linking, and
body text.

What sets VimOutliner apart from the rest is that it's been constructed from
the ground up for fast and easy authoring.  Keystrokes are quick and easy,
especially for someone knowing the Vim editor. The mouse is completely
unnecessary (but is supported to the extent that Vim supports the mouse). Many
of the VimOutliner commands start with a double comma because that's very
quick to type.

Many outliners are prettier than VimOutliner. Most other outliners are more
intuitive for the newbie not knowing Vim. Many outliners are more featureful
than VimOutliner (although VimOutliner gains features monthly and is already
very powerful).  Some outliners are faster on lookup than VimOutliner. But as
far as we know, NO outliner is faster at getting information out of your mind
and into an outline than VimOutliner.

VimOutliner will always give you lightning fast authoring. That's our basic,
underlying philosophy, and will never change, no matter what features are
added.


Vim Integration~

Earlier VimOutliner versions prided themselves on being standalone
applications, self-contained in a single directory with a special script to
run everything.

As of 0.3.0, VimOutliner is packaged as a Vim Plugin, eliminating the need for
the ol script, which many saw as clumsy. Given that all VimOutliner features
are produced by the Vim engine, it makes perfect sense to admit that
VimOutliner is an add-on to Vim.

Therefore VimOutliner now prides itself in being a Vim plugin. With the
VimOutliner package installed, the Vim editor yields the VimOutliner feature
set for files whose extensions are listed as votl types in
$HOME/.vim/ftplugin/votl.vim.


==============================================================================
Running VimOutliner~                                                 *votl-running*


Vim Knowledge~

You needn't be a Vim expert to use VimOutliner. If you know the basics --
inserting and deleting linewise and characterwise, moving between command and
insert modes, use of Visual Mode selections,and reformatting, you should be
well equipped to use VimOutliner.

Run Vim or GVim and follow the instruction on :help |tutor|

VimOutliner is a set of Vim scripts and configurations. Its features all come
from the Vim editor's engine. If you do not know Vim, you'll need to learn the
Vim basics before using VimOutliner. Start by taking the Vim tutorial. The
tutorial should take about 2 hours.

VimOutliner is so fast, that if you often use outlining, you'll make up that
time within a week.

                                                                    *votl-command*
Comma Comma Commands~

For maximum authoring speed, VimOutliner features are accessed through
keyboard commands starting with 2 commas.  The double comma followed by a
character is incredibly fast to type.

We expect to create more comma comma commands, so try not to create your own,
as they may clash with later comma comma commands. If you have an
exceptionally handy command, please report it to the VimOutliner list. Perhaps
others could benefit from it.

    Command   List     Description ~
        ,,D   all      VimOutliner reserved command
        ,,H   all      reserved for manual de-hoisting (add-on)
        ,,h   all      reserved for hoisting (add-on)
        ,,1   all      set foldlevel=0
        ,,2   all      set foldlevel=1
        ,,3   all      set foldlevel=2
        ,,4   all      set foldlevel=3
        ,,5   all      set foldlevel=4
        ,,6   all      set foldlevel=5
        ,,7   all      set foldlevel=6
        ,,8   all      set foldlevel=7
        ,,9   all      set foldlevel=8
        ,,0   all      set foldlevel=99999
        ,,-   all      Draw dashed line
        ,,f   normal   Directory listing of the current directory
        ,,s   normal   Sort sub-tree under cursor ascending
        ,,S   normal   Sort sub-tree under cursor descending
        ,,t   normal   Append timestamp (HH:MM:SS) to heading
        ,,T   normal   Pre-pend timestamp (HH:MM:SS) to heading
        ,,t   insert   Insert timestamp (HH:MM:SS) at cursor
        ,,d   normal   Append datestamp  (YYYY-MM-DD) to heading
        ,,d   insert   Insert datestamp  (YYYY-MM-DD) at cursor
        ,,D   normal   Pre-pend datestamp  (YYYY-MM-DD) to heading
        ,,B   normal   Make body text start with a space
        ,,b   normal   Make body text start with a colon and space
        ,,w   insert   Save changes and return to insert mode
        ,,e   normal   Execute the executable tag line under cursor


Other VimOutliner Commands~

Naturally, almost all Vim commands work in VimOutliner.  Additionally,
VimOutliner adds a few extra commands besides the comma comma commands
discussed previously.

Command list:
    CTRL-K        Follow tag (Synonym for CTRL-])
    CTRL-N        Return from tag (Synonym for CTRL-T)
    Q             Reformat (Synonym for gq)


To get a quick overview of all VimOutliner commands type ":help votl_cheatsheet" in vim.

                                                                 *votl-activities*
Basic VimOutliner activities~

How do I collapse a tree within command mode?
    zc
    (note: a full list of folding commands |fold-commands|)

How do I expand a tree within command mode?
    To expand one level:
        zo
    To expand all the way down
        zO

How do I demote a headline?
    In command mode, >>
    In insert mode at start of the line, press the Tab key
    In insert mode within the headline, CTRL-T

How do I promote a headline?
    In command mode, <<
    In insert mode at start of the line, press the Backspace key
    In insert mode within the headline, CTRL-D

How do I promote or demote several consecutive headlines?
    Highlight the lines with the V command
    Press < to promote or > to demote. You can precede
    the < or > with a count to promote or demote several levels

How do I promote or demote an entire tree?
    Collapse the tree
    Use << or >> as appropriate

How do I collapse an entire outline?
    ,,1

How do I maximally expand an entire outline?
    ,,0

How do I expand an outline down to the third level?
    ,,3

How do I move a tree?
    Use Vim's visual cut and paste

How do I create body text?
    Open a blank line below a headline
    Start the line with a colon followed by a space
    Continue to type. Your text will wrap

How do I reformat body text?
    Highlight (Shift+V) the body text to be reformatted
    Use the gq command to reformat

How do I reformat one paragraph of body text?
    The safest way is highlighting.
        DANGER! Other methods can reformat genuine headlines.

How do I switch between colon based and space based body text?
    ,,b for colon based, ,,B for space based

What if ,,b and ,,B don't work
    Change variable use_space_colon from 1 to 0
        in $HOME/.vim/ftplugin/votl.vim

How do I perform a wordcount?
    Use the command :w !wc
        The space before the exclamation point is a MUST.

                                                                       *votl-menu*
Menu~

There is a simple menu included in Vim Outliner when running in GUI mode.
Named 'VO', you can usually find it right next to the 'Help' menu. There are
commands to change the fold level and select alternate color schemes. There is
also entries for common tools.

The last tool item calls a shell script, 'myotl2html.sh'. This script should
be provided by the user and is not included in VO releases. A sample
myotl2html.sh script might look like this:
>
    #!/bin/bash
    otl2html.py -S pjtstat.css $1 > $HOME/public_html/$1.html
<
If you have several different types of reports you create regularly, you can
create your own menu entries. Just add lines like these to your
~/.vimoutlinerrc file: >
>
    amenu &VO.&Reports.&Big\ Project :!otl2html.py -S big.css % > %.html
    amenu &VO.&Reports.&Hot\ List :!otl2html.py -S todo.css % > %.html
    amenu &VO.&Reports.&Weekly :!otl2html.py -S weekly.css % > %.html
<
I'm sure you get the idea.

                                                                    *votl-objects*
Vim Outliner Objects~

There are several object/line types that VO supports. The most common on
simple headings and body text. Simple headings are tab-indented line that
start with any non-whitespace character except: : ; | < >.  These characters
specify other objects. Here is a list of each of the non-heading types:

    Start    Description~
      :      body text (wrapping)
      ;      preformatted body text (non-wrapping)
      |      table
      >      user-defined, text block (wrapping)
      <      user-defined, preformatted text block (non-wrapping)

The body text marker, :, is used to specify lines that are automatically
wrapped and reformatted. VO and post-processors are free to wrap and reformat
this text as well as use proportionally- spaced fonts. A post-processor will
probably change the appearance of what you have written. If you are writing a
book or other document, most of the information you enter will be body text.

Here is an example:
>
    Kirby the Wonder Dog
    	: Kirby is nine years old. He understand about 70-100
	: English words. Kirby also understands 11 different hand
	: signals. He is affectionate, playful and attentive.
	:
	: His breeding is unknown. He appears to be a mix between
	: a german shepherd and a collie.
<
When folded, body text looks something like this:
>
    Kirby the Wonder Dog
	[TEXT] -------------------------------- (6 lines)
<
The preformatted text marker, ;, is used to mark text that should not be
reformatted nor wrapped by VO or any post-processor. A post- processor would
use a fixed-space font, like courier, to render these lines. A post-processor
will probably not change the appearance of what you have written. This is
useful for making text picture, program code or other format-dependent text.

Here is an example:
>
    Output waveform
	;         _______                ______
	;   _____/       \______________/
	;        |-10us--|----35us------|
<
When folded, preformatted body text looks something like this:
>
    Output waveform
	[TEXT BLOCK] -------------------------- (6 lines)
<
The table marker, |, is used to create tables. This is an excellent way to
show tabular data. The marker is used as if it were are real vertical line. A
|| (double-|) is optionally used to mark a table heading line. This is useful
for post-processors.

Here is an example:
>
	Pets
		|| Name  | Age | Animal | Inside/Outside |
		| Kirby  |   9 |    dog |           both |
		| Hoover |   1 |    dog |           both |
		| Sophia |   9 |    cat |         inside |
<
There is no automatic alignment of columns yet. It must be done manually. The
post-processor, otl2thml.py, does have alignment functions. See its
documentation for more information.

When folded, a table looks something like this:
>
    Pets
	[TABLE] ------------------------------- (4 lines)
<
User-defined text is similar to body text but more flexible and it's use is
not pre-defined by Vim Outliner. The basic, user-defined text block marker, >,
behaves just like body text.

For example:
>
    Kirby the Wonder Dog
    	> Kirby is nine years old. He understand about 70-100
	> English words. Kirby also understands 11 different hand
	> signals. He is affectionate, playful and attentive.
	>
	> His breeding is unknown. He appears to be a mix between
	> a german shepherd and a collie.
<
When folded, body text looks something like this:
>
    Kirby the Wonder Dog
	[USER] -------------------------------- (6 lines)
<
But unlike body text, user-defined text can be expanded. You could have
user-defined text types. If you were writing a book, in addition to body text
for paragraphs you might need special paragraphs for tips and warnings.
User-defined text blocks can accomplish this:
>
	>Tips
	> Don't forget to back up your computer daily. You don't
	> need to back up the entire computer. You just need to
	> backup up the files that have changed.
	>Warning
	>Never store you backup floppy disks on the side of you
	>file cabinets by adhering them with magnets.
<
A post processor will know how to remove the style tags (Tips and Warning) and
you want the text to be formatted.

When folded, the above would appear as:
>
	[USER Tips] --------------------------- (4 lines)
	[USER Warning]------------------------- (3 lines)
<
The user-defined, preformatted text block marker, <, behaves just like
preformatted text. But like >, it leaves the functional definition up to the
user. A simple user-defined, preformatted text block could be:
>
    Tux
	<                 _.._
	<              .-'    `-.
	<             :          ;
	<             ; ,_    _, ;
	<             : \{"  "}/ :
	<            ,'.'"=..=''.'.
	<           ; / \      / \ ;
	<         .' ;   '.__.'   ; '.
	<      .-' .'              '. '-.
	<    .'   ;                  ;   '.
	<   /    /                    \    \
	<  ;    ;                      ;    ;
	<  ;   `-._                  _.-'   ;
	<   ;      ""--.        .--""      ;
	<    '.    _    ;      ;    _    .'
	<    {""..' '._.-.    .-._.' '..""}
	<     \           ;  ;           /
	<      :         :    :         :
	<      :         :.__.:         :
	<       \       /"-..-"\       /    fsc
	<        '-.__.'        '.__.-'
<
When folded it would be:
>
    Tux
	[USER BLOCK] -------------------------- (6 lines)
<
Like user-defined text, these blocks can be given user-defined styles. For
example:
>
	<ASCIIart
	<                 _.._
	<              .-'    `-.
	<             :          ;
	<             ; ,_    _, ;
	<             : \{"  "}/ :
	<            ,'.'"=..=''.'.
	<           ; / \      / \ ;
	<         .' ;   '.__.'   ; '.
	<      .-' .'              '. '-.
	<    .'   ;                  ;   '.
	<   /    /                    \    \
	<  ;    ;                      ;    ;
	<  ;   `-._                  _.-'   ;
	<   ;      ""--.        .--""      ;
	<    '.    _    ;      ;    _    .'
	<    {""..' '._.-.    .-._.' '..""}
	<     \           ;  ;           /
	<      :         :    :         :
	<      :         :.__.:         :
	<       \       /"-..-"\       /    fsc
	<        '-.__.'        '.__.-'
	<Code
	< getRXDN macro
	<
	< 	local	gRXD1, gRXD2
	< 	bcf	STATUS,C
	< 	btfsc	FLAGS,SERPOL
	<
	< 	goto	gRXD1
	< 	btfsc	RXDN
	< 	bsf	STATUS,C
	< 	goto	gRXD2
	<
	< gRXD1	btfss	RXDN
	< 	bsf	STATUS,C
	< 	nop
	< gRXD2
	< 	endm
<
When folded, the above would appear as:
>
	[USER BLOCK ASCIIart] ----------------- (22 lines)
	[USER BLOCK Code] --------------------- (17 lines)
<

                                                            *votl-post-processors*
VimOutliner Post-Processors~

There are already serveral post processors for Vim Outliner. Some are general
purpose in nature and others perform specific conversions. There are several of 
the tested scripts now included in the $HOME/.vim/vimoutliner/scripts folder.
See also the scripts section.                                   |votl-scripts|


==============================================================================
Advanced VimOutliner                                               *votl-advanced*

                                                           *votl-executable-lines*
Executable Lines~

Executable lines enable you to launch any command from a specially constructed
headline within VimOutliner. The line must be constructed like this:
>
    Description _exe_ command
<
Here's an example to pull up Troubleshooters.Com:
>
    Troubleshooters.Com _exe_ mozilla http://www.troubleshooters.com
<
Executable lines offer the huge benefit of a single-source knowledge tree,
where all your knowledge, no matter what its format, exists within a single
tree of outlines connected with inter-outline links and executable lines.

A more efficient and feature rich way to achieve this might be to use the UTL 
plugin for vim. See the scripts section at http://www.vim.org


==============================================================================
Plugins                                                             *votl-plugins*


The VimOutliner distribution currently includes plugins for easy handling
of checkboxes, hoisting (see below), smart paste, clocking, math and format. 

The checkboxes tags and smart paste plugins are enabled by default. The hoisting,,
clocking, math and format plugins are disabled by default. To enable these plugins
look for the easy instructions for this in your $HOME/.vimoutlinerrc file.

More information below and in the plugin files in the $HOME/.vim/vimoutliner/plugin folder.

                                                                   *votl-checkbox*
Checkboxes~

Checkboxes enable VimOutliner to understand tasks and calculate the current
status of todo-lists etc. Three special notations are used:
>
    [_]     an unchecked item or incomplete task
    [X]     a checked item or complete task
    %       a placeholder for percentage of completion
<
Several ,,-commands make up the user interface:
>
    ,,cb  Insert a check box on the current line or each line of the currently
          selected range (including lines in selected but closed folds). This
          command is currently not aware of body text. Automatic recalculation
          of is performed for the entire root-parent branch that contains the
          updated child. (see ,,cz)
    ,,cx  Toggle check box state (percentage aware)
    ,,cd  Delete check boxes
    ,,c%  Create a check box with percentage placeholder except on childless
          parents
    ,,cp  Create a check box with percentage placeholder on all headings
    ,,cz  Compute completion for the tree below the current heading.
<
How do I use it?

Start with a simple example. Let's start planning a small party, say a barbeque.

1. Make the initial outline.
>
    Barbeque
        Guests
            Bill and Barb
            Larry and Louise
            Marty and Mary
            Chris and Christine
            David and Darla
            Noel and Susan
        Food
            Chicken
            Ribs
            Corn on the cob
            Salad
            Desert
        Beverages
            Soda
            Iced Tea
            Beer
        Party Favors
            Squirt guns
            Hats
            Name tags
        Materials
            Paper Plates
            Napkins
            Trash Containers
<

2. Add the check boxes.

This can be done by visually selecting them and typing ,,cb.  When done, you
should see this:
>
    [_] Barbeque
        [_] Guests
            [_] Bill and Barb
            [_] Larry and Louise
            [_] Marty and Mary
            [_] Chris and Christine
            [_] David and Darla
            [_] Noel and Susan
        [_] Food
            [_] Chicken
            [_] Ribs
            [_] Corn on the cob
            [_] Salad
            [_] Desert
        [_] Beverages
            [_] Soda
            [_] Iced Tea
            [_] Beer
        [_] Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] Materials
            [_] Paper Plates
            [_] Napkins
            [_] Trash Containers
<

3. Now check off what's done.

Checking off what is complete is easy with the
,,cx command.  Just place the cursor on a heading and ,,cx it. Now you can see
what's done as long as the outline is fully expanded.
>
    [_] Barbeque
        [_] Guests
            [X] Bill and Barb
            [X] Larry and Louise
            [X] Marty and Mary
            [X] Chris and Christine
            [X] David and Darla
            [X] Noel and Susan
        [_] Food
            [X] Chicken
            [X] Ribs
            [_] Corn on the cob
            [_] Salad
            [X] Desert
        [_] Beverages
            [_] Soda
            [X] Iced Tea
            [X] Beer
        [_] Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] Materials
            [X] Paper Plates
            [_] Napkins
            [X] Trash Containers
<

4. Now summarize what's done.

You can summarize what is done with the ,,cz command.  Place the cursor on the
'Barbeque' heading and ,,cz it.  The command will recursively process the
outline and update the check boxes of the parent headlines. You should see:
(Note: the only change is on the 'Guests' heading. It changed because all of
its children are complete.)
>
    [_] Barbeque
        [X] Guests
            [X] Bill and Barb
            [X] Larry and Louise
            [X] Marty and Mary
            [X] Chris and Christine
            [X] David and Darla
            [X] Noel and Susan
        [_] Food
            [X] Chicken
            [X] Ribs
            [_] Corn on the cob
            [_] Salad
            [X] Desert
        [_] Beverages
            [_] Soda
            [X] Iced Tea
            [X] Beer
        [_] Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] Materials
            [X] Paper Plates
            [_] Napkins
            [X] Trash Containers
<

5. Add percentages for a better view.

You can get a much better view of what's going on, especially with collapsed
headings, if you add percentages.  Place a % on each heading that has children
like this:
>
    [_] % Barbeque
        [X] % Guests
            [X] Bill and Barb
            [X] Larry and Louise
            [X] Marty and Mary
            [X] Chris and Christine
            [X] David and Darla
            [X] Noel and Susan
        [_] % Food
            [X] Chicken
            [X] Ribs
            [_] Corn on the cob
            [_] Salad
            [X] Desert
        [_] % Beverages
            [_] Soda
            [X] Iced Tea
            [X] Beer
        [_] % Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] % Materials
            [X] Paper Plates
            [_] Napkins
            [X] Trash Containers
<

6. Now compute the percentage of completion.

After adding the % symbols, place the cursor on the 'Barbeque' heading and
execute ,,cz as before. Keep in mind that the recursive percentages are
weighted. You should see:
>
    [_] 58% Barbeque
        [X] 100% Guests
            [X] Bill and Barb
            [X] Larry and Louise
            [X] Marty and Mary
            [X] Chris and Christine
            [X] David and Darla
            [X] Noel and Susan
        [_] 60% Food
            [X] Chicken
            [X] Ribs
            [_] Corn on the cob
            [_] Salad
            [X] Desert
        [_] 66% Beverages
            [_] Soda
            [X] Iced Tea
            [X] Beer
        [_] 0% Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] 66% Materials
            [X] Paper Plates
            [_] Napkins
            [X] Trash Containers
<

7. Complete a few more just for fun.

Mark Salad and Soda and you should see the ouline below.  Try plaing around
with zc and zo to see the effects of opening and closing folds. Even if you
place the cursor on 'Barbeque' and zo it, you still have a good understanding
of how complete the project is.
>
    [_] 69% Barbeque
        [X] 100% Guests
            [X] Bill and Barb
            [X] Larry and Louise
            [X] Marty and Mary
            [X] Chris and Christine
            [X] David and Darla
            [X] Noel and Susan
        [_] 80% Food
            [X] Chicken
            [X] Ribs
            [_] Corn on the cob
            [X] Salad
            [X] Desert
        [X] 100% Beverages
            [X] Soda
            [X] Iced Tea
            [X] Beer
        [_] 0% Party Favors
            [_] Squirt guns
            [_] Hats
            [_] Name tags
        [_] 66% Materials
            [X] Paper Plates
            [_] Napkins
            [X] Trash Containers
<
                                                                   *votl-hoisting*
Hoisting~

Hoisting is a way to focus on the offspring of the currently selected outline
item. The subitems will be presented as top level items in the automatically
extracted hoist-file located in the same directory as the main outline file.
You cannot hoist parts of an already hoisted file again.

To enable this plugin uncomment the following line in
 ~/.vimoutlinerrc:
>
    "let g:vo_modules_load .= ':newhoist'
<
Once it is enabled, you hoist the subtopics of the currently selected
item with

    ,,h   Hoist the subtopics into a temporary file

The changes are merged back into the original file by closing the temporary
hoist file with

    :q  :wq  :x  ZZ

If something went wrong, you can perform a manual de-hoisting with the
following procedure:

Open the main file in VimOutliner Search for the line containing the __hoist
tag On this line, do

    ,,H    Manual de-hoisting

                                                                      *vo-clock*
Clock~

The clock plugin is a little imitation of a nice feture from emacs orgmode.
The clockpugin allows to track times and summarize them up in the parent
heading.

To enable this plugin uncomment the following line in ~/.vimoutlinerrc:
>
    "let g:vo_modules_load .= ':clock'
<
To start clocking you need to write a heading containing times in square
brackets like shown below. After the closing bracket -> indicates the place
where the calcualted time is written. The arrow can be followed by a char to
indicate to unit in which the time is displayed. Use 's' for seconds, 'm' for
minutes, 'h' for hours and 'd' for days. If no unit is given hours are used.
>
    Year 2011 -> d
        January ->
            Monday, 3th [08:30:00 -- 17:45:00] -> m
            Tuesday, 3th [08:50:25 -- 18:00:02] -> s
<

To summarize the times up within the outline headings ending with -> {char}
use

    ,,cu    Clock update with the cursor somewhere in the hierarchy.

After that the outline should look like this:
>
    Year 2011 -> 0.77 d
        January -> 18.41 h
            Monday, 3th [08:30:00 -- 17:45:00] -> 555.00 m
            Tuesday, 3th [08:50:25 -- 18:00:02] -> 32977 s
<
Every time the times are changed or the units where changed use ,,cu to update
all times within the hierarchy.

Mappings for fast clocking:

    ,,cs    Clock start. Date and current time as start and endtime are
            written at cursor position. Works in normal mode and insert mode.
>
    Year 2011 -> 0.77 d
        January -> 18.41 h
            Monday, 3th [08:30:00 -- 17:45:00] -> 555.00 m
            Tuesday, 3th [08:50:25 -- 18:00:02] -> 32977 s
            2011-10-11 [01:32:11 -- 01:32:11] ->
>
To set a new endtime, place the cursor at the desired line and use following
mapping:

    ,,cS    Clock stop. Set the endtime to current time. This works also in
            normal mode and insert mode.

>
    Year 2011 -> 0.77 d
        January -> 18.41 h
            Monday, 3th [08:30:00 -- 17:45:00] -> 555.00 m
            Tuesday, 3th [08:50:25 -- 18:00:02] -> 32977 s
            2011-10-11 [01:32:11 -- 01:42:19] -> 0.17 h
>
At the moment there are no userdefined timeformats supported. And it's not
possible to clock times over the midnight like [22:25:00 -- 01:00:00], but
it's usable for the most important cases.


==============================================================================
Scripts                                                           *votl-scripts*


The VimOutliner distribution currently includes several useful  external
scripts to support interoutline links, HTML export and more. All scripts are
included in your $HOME/.vim/vimoutliner/scripts folder. For more information
on these scripts see usage section in the scripts. You can also find several
of these scripts on this web site with links to their specific web site:
https://sites.google.com/site/vimoutlinerinfo/scripts-for-vimoutliner 


Information on some of the scripts

votl_maketags.pl                                                 *votl-maketags*

A basic description of how to use this Perl script is given in section
|votl-testing|, subsection "Verify interoutline linking".

otl2html.py                                                           *otl2html*

This Python script transforms an outline into an HTML file. Use $ otl2html.py
--help to get detailed information.

This script does not adhere to the VimOutliner naming convention with the
'votl_' prefix because it is not necessary for any VimOutliner functionality.
It is provided both as a useful tool for creating HTML pages and HTML slides
from outlines and as a working demonstration of how to convert .otl files to
other formats.


==============================================================================
Other Information                                              *votl-other-info*


The VimOutliner Project~

- How do I add my own features?
Two ways -- by changing VimOutliner source code, or by inserting your own code
in $HOME/.vimoutlinerrc, which runs at the end of the VimOutliner startup
scripts. You might have to merge your personal .vimoutlinerrc with future
versions to take advantage of new features.

- How is VimOutliner licensed?
VimOutliner is licensed under the GNU General Public License.

- How do I contribute to VimOutliner
Step 1 is to subscribe to our mailing list. Join up at
https://groups.google.com/forum/#!forum/vimoutliner. 
Lurk for a few days or so to get the feel, then submit your idea/suggestion. 
A lively discussion will ensue, after which your idea, probably in some modified
form, will be considered. The more of the actual work you have done, the more 
likely your feature will go in the distribution in a timely manner.


- What's with the VimOutliner file names?
All VimOutliner files must begin with votl_ unless Vim itself requires them to
have a different name. A few older files from previous versions break this
rule, but over time these will be changed to our naming convention.

In the old days, with the "self contained" philosophy, there was no naming
convention, because VimOutliner files were segregated into their own tree.
With the coming of the "vim plugin" philosophy, there's a need to identify
VimOutliner files for purposes of modification, upgrade and de-installation.
Hence our naming convention.

- What if my feature doesn't make it into the VimOutliner distribution?
You can offer it on your own website, or very possibly on
to the forthcoming new VimOutliner home page  VimOutliner ships with its
core features, but many additional functionalities, especially those that
operate from Perl scripts (or bash or python) are available outside the
distro. For instance, right now there's an Executable Line feature that turns
VimOutliner into a true single tree information reservoir. The Executable Line
feature is available extra-distro on the VimOutliner home page. See also the
scripts included in the $HOME/.vim/vimoutliner/scripts folder.


Anticipated improvements in later versions~

Command-invoking headlines
    Already prototyped
    Probably coming next version
    Allows you to press a key and get an html command in a browser
    Enables a true single tree knowledge collection
    Enables use of VimOutliner as a shell

Groupware
    Not yet well defined
    Enables collaborative work on an outline
    A pipedream, but VimOutliner itself was once a pipedream

Easy mode
    Let's Windows users operate VO like a common insert-only editor. This will
    remove a great deal of VO's keyboarder- friendly features. But then,
    they're Windows users: let them use the mouse.

Headline to headline links
    Not yet sanctioned, might never be implemented If implemented, this would
    presumably create links not just between outlines, but between headlines,
    either in the same outline or in a different one. This would be a start on
    "neural networking".

Headline numbering
    Under feasibility investigation
    Supported by external scripts

Toolbar in gvim
    Under feasibility investigation


Further information on outlines, outline processing and outliners~

http://www.vim.org/scripts/script.php?script_id=3515
vim.org script site

http://freecode.com/projects/vimoutliner
Main distribution website

https://github.com/vimoutliner/vimoutliner
git repository

http://www.troubleshooters.com/projects/alt-vimoutliner-litt/
Preliminary main web site with links to other sites

http://www.troubleshooters.com/tpromag/199911/199911.htm
Outlining discussion, not product specific

http://www.troubleshooters.com/linux/olvim.htm
Discussion on how to use Vim for outlining

http://www.troubleshooters.com/projects/vimoutliner.htm
Former Webpage for the VimOutliner distro

http://www.outliners.com
Discussion of (proprietary) outliners from days gone by.
Downloads for ancient versions of such outliners.
Unfortunately, all are dos, windows and mac.

http://members.ozemail.com.au/~caveman/Creative/Software/Inspiration/index.html
Discussion of (proprietary,Mac) Inspiration software
This page discusses many methods of thought/computer interaction:
    Visual Outlining
    Textual Outlining
    Idea mapping
    Mind Mapping
    Brainstorming with Rapid Fire Entry
    Concept Mapping
    Storyboarding
    Diagrams (using rich symbol library)

http://members.ozemail.com.au/~caveman/Creative/index.html
Not about outlines, but instead about how to use your brain.
The whole purpose of outlines is to use your brain.
New ways of using your brain produce new ways to use outlines.

For the VimOutliner version information and history, see the CHANGELOG. 

 vim:tw=78:et:ft=help:norl:
