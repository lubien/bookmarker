defmodule Bookmarker.Runner do
  alias Bookmarker.Bookmark
  alias Bookmarker.Template

  def run(config) do
    get_bookmarks(config.file)
    |> ignore_paths(config.ignore)
    |> render_markdown(Map.take(config, [:title, :description, :timestamp]))
    |> output(config.output)
  end

  def get_bookmarks(file) do
    file
    |> Path.expand
    |> File.read!
    |> Poison.decode!
    |> Map.fetch!("roots")
    |> Map.fetch!("other")
  end

  def ignore_paths(bookmarks, paths) do
    paths
      |> Enum.reduce(bookmarks, fn path, acc ->
        Bookmark.drop_at(acc, String.split(path, "/"))
      end)
  end

  def render_markdown(bookmarks, config) do
    Template.render(bookmarks, config)
  end

  def output(rendered, path)
  when is_binary(path) do
    dest = path |> Path.expand
    dest |> File.write!(rendered)
    IO.puts "Saved output at #{dest}"
  end
  def output(rendered, _target) do
    IO.puts rendered
  end
end
