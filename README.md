**VimOutliner README file**

Introduction
============

VimOutliner is an outline processor with many of the same features
as Grandview, More, Thinktank, Ecco, etc. Features include tree
expand/collapse, tree promotion/demotion, level sensitive colors,
interoutline linking, and body text.

What sets VimOutliner apart from the rest is that it's been constructed
from the ground up for fast and easy authoring.  Keystrokes are quick and
easy, especially for someone knowing the Vim editor. VimOutliner can be
used without the mouse (but is supported to the extent that Vim supports
the mouse). 

All VimOutliner files have the `.otl` extension. For help on
VimOutliner type `:h vo`. For an overview of all the most important
VimOutliner commands you can type `:h votl_cheatsheet` when you have
opened an otl file.


Usage
=====
VimOutliner has been reported to help with the following tasks:

    - Project management
    - Password wallet
    - To-do lists
    - Account and cash book
    - 'Plot device' for writing novels
    - Inventory control
    - Hierarchical database
    - Web site management

Characteristics
===============

    - Fast and effective
    - Fully integrated with Vim
    - Extensible through plugins
    - Many post-processing scripts allow exporting to multiple formats
    - Extensive documentation

See the [help file](doc/votl.txt) for further information.  After
installation you can access it from within vim using `:h vo`.

If something does not work, please, let us know (either on the email
list or file a ticket to the GitHub issue tracker).

Downloads
=========
If your goal is to install vimoutliner, see the next section rather
than using these options.

[zip archives](https://github.com/vimoutliner/vimoutliner/downloads)

Download of all packages can also be done from the [Freshmeat
site](http://freecode.com/projects/vimoutliner).

Installation
============

If there is a pre-packaged version available for your operating
system, use that.  Otherwise, read on.

Prerequisites
-------------

- vim
- git*

Some of the provided scripts have additional requirements.  If you
want to run them, you will need  appropriate support.  The python
scripts need Python 3 and the perl scripts need Perl.

*There are other ways of getting the source code if you don't want to
use git, e.g., the downloads in the previous section.  But these
instructions will assume git.

Standard Install
----------------

VimOutliner uses the now standard method of installation of vim
plugins (vim version 8 is shown, but similar steps for older versions
of vim could work with using vim-pathogen, Vundle):
```shell
   $ mkdir -p ~/.vim/pack/thirdparty/start  # the "thirdparty" name may
                                            # be different, there just
                                            # need to be one more level
                                            # of directories
   $ cd ~/.vim/pack/thirdparty/start
   $ git clone https://github.com/vimoutliner/vimoutliner.git
   $ vim -u NONE -c "helptags vimoutliner/doc" -c q
```

See Helper Scripts below for additional setup for external scripts.

Submodule Install
------------------

Alternatively instead of making a clone as a separate repo, the
developers of VimOutliner believe, it is better to have whole ~/.vim
directory as one git repo and then vim plugins would be just submodules.
If you have setup ~/.vim in this way then installing VimOutliner is
just:
```shell
   $ cd ~/.vim/
   $ git submodule add https://github.com/vimoutliner/vimoutliner.git \
        pack/thirdparty/start/vimoutliner
   $ vim -u NONE -c "helptags vimoutliner/doc" -c q
```
Restart vim and you should be good to go. 

Getting all your vim plugins updated would be then just
```shell
   $ cd ~/.vim
   $ git submodule update --remote --rebase
```
For more about working with git submodules, read git-submodule(1).

Helper Scripts
--------------
VimOutliner comes with a variety of helper scripts that can be run
outside of vim.  None are necessary for the basic outlining behavior
of VimOutliner.  If you do want to use them, you will probably want to
make it easy to access them.

If you followed the standard installation instructions, the scripts
are in
`~/.vim/pack/thirdparty/start/vimoutliner/vimoutliner/scripts/`.  They
will be under the submodule if you followed the alternate installation
instructions.   If you want to run them, you
will probably want a convenient way to access them.  Here are some
possibilities:

	1. Add that directory to your PATH.
	2. Only invoke them from menus within vim.
	3. Make links or copies of files you want to use to
	   a directory already in your path.
In all cases you should leave the originals in place, as various parts
of the system may assume they are there (e.g., the menus in option 2).

Testing the Installation
------------------------
Open a new outline with the following:
```shell
    rm $HOME/votl_test.otl
    gvim $HOME/votl_test.otl # or 
	vim $HOME/votl_test.otl
```

Verify the following:
- Tabs indent the text
- Different indent levels are different colors
- Lines starting with a colon and space word-wrap

  Lines starting with colons are body text. They should word wrap and
  should be a special color (typically green, but it can vary). Verify
  that paragraphs of body text can be reformatted with the Vim gq
  commands.

If you plan to use particular features, you may want to test them
too. In the online help, |votl-checkbox| discusses expected behavior
of checkboxes, and |votl-maketags| provides explicit instructions for
a simple test of interoutline linking.



