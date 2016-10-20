defmodule Bookmarker.CLI do
  alias Bookmarker.Runner

  @option_parser_opts [
    strict: [
      help: :boolean,
      file: :string,
      title: :string,
      description: :string,
      ignore: :keep,
      output: :string,
    ],
    aliases: [
      h: :help,
      f: :file,
      t: :title,
      d: :description,
      i: :ignore,
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
            Keyword.get(params, :file, Application.get_env(:bookmarker, :bookmarks_file)),
          title:
            Keyword.get(params, :title, Application.get_env(:bookmarker, :default_title)),
          description:
            Keyword.get(params, :description, Application.get_env(:bookmarker, :default_description)),
          ignore:
            Keyword.get_values(params, :ignore),
          output:
            Keyword.get(params, :output, :stdio),
        }
    end
  end

  defp process(:help) do
    IO.puts """
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
    """
  end

  defp process(config) do
    Runner.run(config)
  end
end
