# Bookmarker

[![Build Status](https://travis-ci.org/lubien/bookmarker.svg?branch=master)](https://travis-ci.org/lubien/bookmarker)

> Convert your Google Chrome's bookmarks into markdown files

## Build

Enter the cloned repo folder then:

```
mix deps.get
mix #=> aliased mix.escript_build
```

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
    # output into your stdout.

  bookmarker -i "Foo/Bar"
    # ignore the folder named Bar inside Foo.

  bookmarker -o "./fo.md"
    # save rendered markdown into a file named "fo.md" in your cwd.
```

## License

[MIT](LICENSE.md)
