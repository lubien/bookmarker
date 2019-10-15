defmodule Bookmarker.Runner do
  alias Bookmarker.{Bookmark, Template}

  def run(config) do
    get_bookmarks(config.file)
    |> ignore_paths(config.ignore)
    |> restrict_to(config.path)
    |> order_bookmarks(config.sort)
    |> render_markdown(Map.take(config, [:title, :description, :timestamp?]))
    |> output(config.output)
  end

  @spec order_bookmarks(any, any) :: any
  defp order_bookmarks(bookmarks, true), do: order_bookmarks(bookmarks)
  defp order_bookmarks(bookmarks, false), do: bookmarks

  defp order_bookmarks(%{"children" => children} = bookmarks) do
    IO.inspect(bookmarks)
    sorted_children = Enum.sort_by(
      order_bookmarks(children),
      &({Map.fetch!(&1, "name"), Map.fetch!(&1, "type")}),
      fn {name1, type1}, {name2, type2} ->
        (type1 != type2 && type1 != "folder") || (type1 == type2 && String.downcase(name1) < String.downcase(name2))
      end
    )
    Map.put(bookmarks, "children", sorted_children)
  end
  defp order_bookmarks([bookmark | rest]), do: [order_bookmarks(bookmark) | order_bookmarks(rest)]
  defp order_bookmarks([]), do: []
  defp order_bookmarks(bookmark), do: bookmark

  @spec get_bookmarks(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | char,
              binary | []
            )
        ) :: %{optional(<<_::64>>) => [any]}
  def get_bookmarks(file) do
    file
    |> Path.expand()
    |> File.read!()
    |> Poison.decode!()
    |> get_other_with_bookmark_bar
  end

  defp get_other_with_bookmark_bar(bookmark_map) do
    roots =
      bookmark_map
      |> Map.fetch!("roots")

    other = Map.fetch!(roots, "other")

    %{
      "children" =>
        Map.fetch!(other, "children") ++
          if(Map.has_key?(roots, "bookmark_bar"),
            do: [Map.fetch!(roots, "bookmark_bar")],
            else: []
          )
    }
  end

  @spec ignore_paths(any, any) :: any
  def ignore_paths(bookmarks, paths) do
    paths
    |> Enum.reduce(bookmarks, fn path, acc ->
      Bookmark.drop_at(acc, String.split(path, "/"))
    end)
  end

  @spec restrict_to(any, any) :: any
  def restrict_to(bookmarks, path) do
    Bookmark.get_at(bookmarks, path)
  end

  def render_markdown(bookmarks, config) do
    Template.render(bookmarks, config)
  end

  def output(rendered, path)
      when is_binary(path) do
    dest = Path.expand(path)
    File.write!(dest, rendered)
    IO.puts("Saved output at #{dest}")
  end
  def output(rendered, _target) do
    IO.puts(rendered)
  end
end
