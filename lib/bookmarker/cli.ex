defmodule Bookmarker.CLI do
  alias Bookmarker.Runner

  @option_parser_opts [
    strict: [
      help: :boolean,
      file: :string,
      title: :string,
      order: :boolean,
      description: :string,
      timestamp: :boolean,
      ignore: :keep,
      path: :string,
      output: :string,
    ],
    aliases: [
      h: :help,
      f: :file,
      t: :title,
      or: :order,
      d: :description,
      i: :ignore,
      p: :path,
      o: :output,
    ]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> build_config
    |> process
  end

  def parse_args(args) do
    args
    |> OptionParser.parse(@option_parser_opts)
    |> elem(0)
  end

  def build_config(params) do
    case params do
      [ help: true ] ->
        :help
      _ ->
        %{
          file:
            Keyword.get(params, :file, 
            case :os.type() do
              {:unix, :darwin} -> 
                Application.get_env(:bookmarker, :osx_bookmarks_file)
              {:unix, _} -> 
                Application.get_env(:bookmarker, :linux_bookmarks_file)
              {:win32, _} -> 
                Application.get_env(:bookmarker, :windows_bookmarks_file)
              end),
          title:
            Keyword.get(params, :title, Application.get_env(:bookmarker, :default_title)),
          description:
            Keyword.get(params, :description, Application.get_env(:bookmarker, :default_description)),
          timestamp?:
            Keyword.get(params, :timestamp, true),
          ignore:
            Keyword.get_values(params, :ignore),
          path:
            Keyword.get(params, :path),
          output:
            Keyword.get(params, :output, :stdio),
          order: Keyword.get(params, :order, false),
    }
    end
  end

  defp process(:help) do
    IO.puts """
    Usage: bookmarker [options]

      -f, --file            Set where your chrome bookmarks file is.
                            Default: ~/.config/google-chrome/Default/Bookemarks
      -t, --title           Set a title for the rendered markdown.
                            Default: Google Chrome Bookmarks
      -d, --description     Set a description for the rendered markdown.
                            Default: Generated by Bookmarker
      -or, --order          Set if the list is ordered
                            Default: false
      --no-timestamp        Prevent appending of build datetime after description.
                            Default: use timestamp
      -i, --ignore          Ignore folders. You may set this multiple times.
      -p, --path            Restrict to folder. You may set this one time only.
      -o, --output          Save rendered markdown to a file.
                            Default: none (output to stdin)

    Examples:

      bookmarker
        # output into your stdout.

      bookmarker -i "Foo/Bar"
        # ignore the folder named Bar inside Foo.

      bookmarker -o "./foo.md"
        # save rendered markdown into a file named "foo.md" in your cwd.
    """
  end

  defp process(config) do
    Runner.run config
  end
end
