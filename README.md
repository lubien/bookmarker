# Bookmarker

Convert your Google Chrome's bookmarks into markdown files

## Usage

```
Usage: bookmarker [options]

  -f, --file            Set where your chrome bookmarks file is.
  -t, --title           Set a title for the rendered markdown.
  -d, --description     Set a description for the rendered markdown.
  -i, --ignore          Ignore folders. You may set this multiple times.
  -o, --output          Save rendered markdown to a file.

Examples:

  bookmarker
    # output into your stdout

  bookmarker -i "Foo/Bar"
    # ignore the folder named Bar inside Foo

  bookmarker -o "./fo.md"
    # save rendered markdown into a file named "fo.md" in your cwd.
```
