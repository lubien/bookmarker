defmodule Bookmarker.Runner do
  alias Bookmarker.{Bookmark, Template}

  @valid_sort_strategies ~w(name-asc name-desc bookmark-count-asc bookmark-count-desc)
  def valid_sort_strategies(), do: @valid_sort_strategies

  def run(config) do
    get_bookmarks(config.file)
    |> ignore_paths(config.ignore)
    |> restrict_to(config.path)
    |> sort_bookmarks(config.sort, config.sortby)
    |> render_markdown(Map.take(config, [:title, :description, :timestamp?]))
    |> output(config.output)
  end

  defp sort_bookmarks(bookmarks, false, nil), do: bookmarks
  defp sort_bookmarks(bookmarks, true, nil), do: sort_bookmarks(bookmarks, "name-asc")
  defp sort_bookmarks(bookmarks, _, strategy), do: sort_bookmarks(bookmarks, strategy)

  defp sort_bookmarks(%{"children" => children} = bookmarks, strategy) do
    sorted_children = sort_bookmarks(children, strategy)
    |> sort_bookmarks_by(strategy)
    Map.put(bookmarks, "children", sorted_children)
  end
  defp sort_bookmarks([bookmark | rest], strategy), do: [sort_bookmarks(bookmark, strategy) | sort_bookmarks(rest, strategy)]
  defp sort_bookmarks([], _), do: []
  defp sort_bookmarks(bookmark, _), do: bookmark

  defp sort_bookmarks_by(bookmarks, "name-asc"), do: sort_bookmarks_by(bookmarks, :name, &(</2))
  defp sort_bookmarks_by(bookmarks, "name-desc"), do: sort_bookmarks_by(bookmarks, :name, &(>/2))
  defp sort_bookmarks_by(bookmarks, "bookmark-count-asc"), do: sort_bookmarks_by(bookmarks, :bookmarkcount, &(</2))
  defp sort_bookmarks_by(bookmarks, "bookmark-count-desc"), do: sort_bookmarks_by(bookmarks, :bookmarkcount, &(>/2))

  defp sort_bookmarks_by(bookmarks, :name, comparer) do
    Enum.sort_by(
      bookmarks,
      &({Map.fetch!(&1, "name"), Map.fetch!(&1, "type")}),
      fn {name1, type1}, {name2, type2} ->
        (type1 != type2 && type1 != "folder") || (type1 == type2 && comparer.(String.downcase(name1), String.downcase(name2)))
      end
    )
  end
  defp sort_bookmarks_by(bookmarks, :bookmarkcount, comparer) do
    Enum.sort_by(
      bookmarks,
      &({Map.fetch!(&1, "name"), Map.fetch!(&1, "type"), &1}),
      fn {name1, type1, bookmark1}, {name2, type2, bookmark2} ->
        len1 = Map.get(bookmark1, "children", []) |> length
        len2 = Map.get(bookmark2, "children", []) |> length
        (type1 != type2 && type1 != "folder")
        || (type1 == "folder" && type2 == "folder" && comparer.(len1, len2))
        || (type1 == type2 && String.downcase(name1) < String.downcase(name2))
      end
    )
  end

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
