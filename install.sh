#!/bin/bash

homedir=$HOME
#homedir=./test
vimdir=$homedir/.vim
vodir=$vimdir/vimoutliner
OS=`uname`

#BACKUP FILE NAMES
bext=`date +_%T_%F.old`
if [ $OS = Linux ] ; then 
       backupargs="-bS $bext"
elif [ $OS = FreeBSD ] ; then
       backupargs="-bB $bext"
else backupargs="";
fi


#SOME FUNCTIONS
sure () {
	read REPLY
	echo
	test $REPLY = "y" || test $REPLY = "Y"
}

make_dir () {
	  test -d $1 || {
		  echo "    creating: $1"
		  mkdir $1
		  created=1
  	}
}

copyfile () {
	echo "    installing: $2/$1"
	install $backupargs $1 $2/$1
}

copydir () {
	files=`ls $1`
	for i in $files; do 
		echo "    installing: $2/$i"
		if [ -d $1/$i ]; then
			mkdir -p $2/$i
			copydir $1/$i $2/$i
		else
			install $backupargs $1/$i $2
		fi
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
echo -n "Would you like to continue (y/N) ? "
sure || exit


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
make_dir $vodir/plugin
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
copyfile doc/vo_cheatsheet.txt $vimdir
copyfile colors/vo_dark.vim $vimdir
copyfile colors/vo_light.vim $vimdir
copyfile vimoutliner/vimoutlinerrc $vimdir
copyfile vimoutliner/scripts/vo_maketags.pl $vimdir

#INCORPORATE DOCS
echo installing documentation
vim -c "helptags $HOME/.vim/doc" -c q

#INSTALL THE ADD-ONS
cat <<EOT
Add-ons
    There are optional Vim Outliner plugins to handle checkboxes, hoisting and
    smartpaste. There is also a script to convert a Vim Outliner .otl file
    to a html file, as well as many other external scripts included. 
    The plugins will be stored in $vodir/plugin and the scripts will be installed in 
    $vodir/scripts.

EOT

echo -n "Would you like to install these (y/N) "
if sure; then
	echo installing add-ons
	copydir vimoutliner/plugin $vodir/plugin
	copydir vimoutliner/scripts $vodir/scripts
fi

#ALL DONE
echo Installation complete

cat <<EOT

**********************************************************************
* For help with using VimOutliner simply execute ":help vo" within   *
* vim. For a quick overview of all commands execute:                 * 
* ":help vo_cheatsheet"                                              *
*                                                                    *
* Additional scripts are available in the scripts folder, see        *
* $HOME/.vim/vimoutliner/scripts                                     *
**********************************************************************

EOT
