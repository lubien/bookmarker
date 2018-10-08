defmodule Bookmarker.Runner do
  alias Bookmarker.Bookmark
  alias Bookmarker.Template

  def run(config) do
    get_bookmarks(config.file)
    |> ignore_paths(config.ignore)
    |> restrict_to(config.path)
    |> order_bookmarks
    |> render_markdown(Map.take(config, [:title, :description, :timestamp?]))
    |> output(config.output)
  end

  defp order_bookmarks(bookmarks) do
    if bookmarks.order do
      Enum.sort_by(bookmarks, fn(b) -> b.title end)
    else
      bookmarks
    end
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
      Bookmark.drop_at acc, String.split(path, "/")
    end)
  end

  def restrict_to(bookmarks, path) do
      Bookmark.get_at bookmarks, path
  end

  def render_markdown(bookmarks, config) do
    Template.render bookmarks, config
  end

  def output(rendered, path)
  when is_binary(path) do
    dest = Path.expand path
    File.write! dest, rendered
    IO.puts "Saved output at #{dest}"
  end

  def output(rendered, _target) do
    IO.puts rendered
  end
end
