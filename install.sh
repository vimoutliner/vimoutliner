#!/bin/bash

homedir=$HOME
#homedir=./test
vimdir=$homedir/.vim
vodir=$homedir/.vimoutliner
OS=`uname`

#BACKUP FILE NAMES
bext=`date +_%T_%F.old`
if [ $OS == Linux ] ; then 
       backupargs="-bS $bext"
elif [ $OS == FreeBSD ] ; then
       backupargs="-bB $bext"
else backupargs="";
fi


#SOME FUNCTIONS
function sure? {
	read -p" (y/N)? " 
	echo
	test $REPLY = "y" || test $REPLY = "Y"
}

function make_dir {
	  test -d $1 || {
		  echo "    creating: $1"
		  mkdir $1
		  created=1
  	}
}

function copyfile {
	echo "    installing: $2/$1"
	install $backupargs $1 $2/$1
}

function copydir {
	files=`ls $1`
	for i in $files; do 
		echo "    installing: $2/$i"
		install $backupargs $1/$i $2
	 done
}

#START THE INSTALL
cat <<EOT
Vim Outliner Installation
    This script is safe for installing Vim Outliner and for upgrading an
    existing Vim Outliner installation. Existing files will be backed-up
    with this extension: $bext. This will simplify
    recovery of any of the old files.

EOT
echo -n "Would you like to continue "
sure? || exit


#CREATE NECESSARY DIRECTORIES
created=0
echo checking/creating needed directories
make_dir $vimdir
make_dir $vimdir/syntax
make_dir $vimdir/ftplugin
make_dir $vimdir/ftdetect
make_dir $vimdir/doc
make_dir $vimdir/colors
make_dir $vodir
make_dir $vodir/plugins
make_dir $vodir/scripts
if [ $created -eq 0 ]; then echo "    none created"; fi

#TWEAK .vimrc
modified=0
echo checking/creating/modifying $homedir/.vimrc
test -f $homedir/.vimrc || { echo "    creating $homedir/.vimrc"
                            touch $homedir/.vimrc
		    }
egrep -lq "filetype[[:space:]]+plugin[[:space:]]+indent[[:space:]]+on" $homedir/.vimrc || \
        { modified=1
	  echo "filetype plugin indent on" >> $homedir/.vimrc
	  }
egrep -lq "syntax[[:space:]]+on" $homedir/.vimrc || \
        { modified=1
	  echo "syntax on" >> $homedir/.vimrc
	  }
if [ $modified -eq 0 ] ; then 
	echo "    not modified"; 
else
	echo "    modifying $homedir/.vimrc"
fi

#TWEAK .vim/filetype.vim
modified=0
echo checking/creating/modifying $homedir/.vim/filetype.vim
test -f $homedir/.vim/filetype.vim || \
       { echo "    creating $homedir/.vim/filetype.vim"
       touch $homedir/.vim/filetype.vim 
       }
egrep -lq "runtime\! ftdetect/\*.vim" $homedir/.vim/filetype.vim || \
       { echo "    modifying $homedir/.vim/filetype.vim"
	 modified=1
         echo "runtime! ftdetect/*.vim" >> $homedir/.vim/filetype.vim
       }
if [ $modified -eq 0 ] ; then echo "    not modified"; fi

#COPY FILES AND BACKUP ANY EXISTING FILES
echo "installing files and making backups if necessary (*$bext)"
copyfile syntax/vo_base.vim $vimdir
copyfile ftplugin/vo_base.vim $vimdir
copyfile ftdetect/vo_base.vim $vimdir
copyfile doc/vo_readme.txt $vimdir
copyfile colors/vo_dark.vim $vimdir
copyfile colors/vo_light.vim $vimdir
copyfile scripts/vo_maketags.pl $vodir
cp -f vimoutlinerrc .vimoutlinerrc
copyfile .vimoutlinerrc $homedir

#INCORPORATE DOCS
echo installing documentation
vim -c "helptags $HOME/.vim/doc" -c q

#INSTALL THE ADD-ONS
cat <<EOT
Add-ons
    There are optional Vim Outliner plugins to handle hoisting and
    checkboxes and a script to convert a Vim Outliner .otl file
    to an html file. If installed, they must be enabled in the 
    .vimoutlinerrc file in your home directory. These files will be 
    stored in $vodir/plugins and 
    $vodir/scripts.

EOT

echo -n "Would you like to install these "
if sure?; then
	echo installing add-ons
	copydir add-ons/plugins $vodir/plugins
	copydir add-ons/scripts $vodir/scripts
fi

#ALL DONE
echo installation complete

cat <<EOT

**********************************************************************
* For help about Vim Outliner simply exececute "help vo" from within *
* vim.                                                               *
*                                                                    *
* Additional scripts and plugins are available on the Vim Outliner   *
* website: www.vimoutliner.org.                                      *
**********************************************************************

EOT
