#!/usr/bin/env python
"""
A script that converts Emacs SES spreadsheet files to a few other
spreadsheet formats (CSV, Excel, HTML).
"""
__author__ = 'Martin Blais <blais@furius.ca>'
__license__ = 'GNU GPL'

import sys, os, re, string
from collections import defaultdict


def main():
    import optparse
    parser = optparse.OptionParser(__doc__.strip())
    opts, args = parser.parse_args()

    if len(args) < 2:
        parser.error("Usage: [SESFILE] [OUTPUT] [OUTPUT] ...")
    source, targets = args[0], args[1:]

    # Skip the text rendering section.
    f = iter(open(source))
    for line in f:
        if re.match("^\f", line):
            break

    # Parse the regular LISP into a dict of col/row entries.
    contents = defaultdict(dict) # int.row -> dict of (col -> text)
    for line in f:
        mo = re.match('\\(ses-cell ([A-Z]+)([0-9]+) (?:\"([^\"]*)\"|nil)', line)
        if not mo:
            continue
        col, row, text = mo.groups()
        row = int(row)
        contents[row].update( [(col, text)] )

    maxwidth = max(map(len, contents.itervalues()))
    hcols = [string.uppercase[i] for i in xrange(maxwidth)]


    for target in targets:
        iterrows = xrange(1, max(contents.iterkeys()))

        # Convert into a csv format.
        if re.match(r'.*\.csv$', target):
            import csv
            w = csv.writer(open(target, 'w'))
            for i in iterrows:
                rowcells = contents[i]
                cells = [rowcells.get(c, '') for c in hcols]
                w.writerow(cells)

        # Convert into an Excel format.
        elif re.match(r'.*\.xls$', target):
            import xlwt
            wb = xlwt.Workbook()
            ws = wb.add_sheet(source)
            for row in iterrows:
                rowcells = contents[row]
                cells = [rowcells.get(c, '') for c in hcols]
                for col, text in enumerate(cells):
                    ws.write(row-1, col, text)
            wb.save(target)

        # Convert into a simple HTML format.
        elif re.match(r'.*\.html$', target):
            f = open(target, 'w')
            f.write(_html_pre % {'title': source}) # FIXME: Should escape here.
            for row in iterrows:
                rowcells = contents[row]
                cells = [rowcells.get(c, '') for c in hcols]
                f.write("      <tr>\n")
                for col, text in enumerate(cells):
                    f.write("        <td>%s</td>\n" % (text or ''))
                f.write("      </tr>\n")
            f.write(_html_post)
            f.close()

_html_pre = """\
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> 
  <head> 
    <title>%(title)s</title> 
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> 
  </head> 
  <body> 
    
    <table>
"""

_html_post = """\
    </table>
  </body>
</html>
"""


if __name__ == '__main__':
    main()
