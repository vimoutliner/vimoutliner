#!/usr/bin/env python
# -*- coding: utf-8 -*-
#   Based on votl_maketags.pl
#   Copyright (C) 2001-2003, 2011 by Steve Litt (slitt@troubleshooters.com)
#   This script is
#   Copyright (C) 2015 Matěj Cepl <mcepl@cepl.eu>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, see <http://www.gnu.org/licenses/>.
from __future__ import print_function, unicode_literals

import argparse
import os.path
import re
import errno


TAGFILENAME = os.path.expanduser("~/.vim/vimoutliner/vo_tags.tag")

TAG_RE = re.compile(r'''
^\s*(?P<tagname>_tag_\S+).*
    \n # and on the next line
    ^\s*(?P<filename>.*)
''', re.VERBOSE | re.MULTILINE)


def append_tags_to_tagfile(tags, outfile):
    for tag in tags:
        print("{0}\t{1}\t:1".format(tag, tags[tag]), file=outfile)


def process_file(filename):
    f = os.path.abspath(filename)
    f_contents = open(f, 'r').read()
    f_tags = {}

    for match in TAG_RE.finditer(f_contents):
        f_tags[match.group('tagname')] = \
            match.group('filename')

    return f_tags


def create_and_process(filename, outfile, queue, filestag):
    filename = os.path.abspath(filename)

    if filename in filestag:
        return

    basedir = os.path.dirname(filename)

    if not os.path.exists(filename):
        try:
            os.makedirs(basedir)
        except OSError as ose:
            if ose.errno == errno.EEXIST and os.path.isdir(basedir):
                pass
            else:
                raise
        open(filename, 'a')
        filestag[filename] = {}
    else:
        results = process_file(filename)
        for tag in results:
            results[tag] = os.path.abspath(os.path.join(basedir, results[tag]))
        queue.extend(results.values())

        append_tags_to_tagfile(results, outfile)

        # let's store all the tags (useful for debugging)
        filestag[filename] = results


def sort_and_dedupe_tagfile():
    sorted_set = sorted(set(open(TAGFILENAME, 'r').readlines()))
    with open(TAGFILENAME, 'w') as tagfile:
        tagfile.writelines(sorted_set)


def main():
    # dict containing a map from a filename to its tag names
    # { filename => { tagname => filename } }
    files_to_tags = {}
    parser = argparse.ArgumentParser()
    parser.add_argument('files', nargs="+",
                        help='directories with data')
    args = parser.parse_args()
    process_queue = args.files

    tagfile = open(TAGFILENAME, 'a')

    for otl_file in process_queue:
        create_and_process(otl_file, tagfile, process_queue,
                           files_to_tags)

    tagfile.close()
    sort_and_dedupe_tagfile()


if __name__ == '__main__':
    main()
