defmodule Bookmarker.Bookmark do
  def drop_at(bookmarks, []), do: bookmarks

  def drop_at(bookmarks, [dir | []]) do
    bookmarks
    |> Map.update("children", [], fn children ->
      Enum.filter(children, fn child -> child["name"] != dir end)
    end)
  end

  def drop_at(bookmarks, directories) do
    bookmarks
    |> Map.update("children", [], fn children ->
      drop_child(children, directories)
    end)
  end

  def get_at(bookmarks, nil), do: bookmarks

  def get_at(bookmarks, dir) do
    bookmarks
    |> Map.update("children", [], fn children ->
      Enum.filter(children, fn child -> child["name"] == dir end)
    end)
  end

  defp drop_child(children, [dir | tail]) do
    Enum.map(children, fn child ->
      if child["name"] == dir do
        drop_at(child, tail)
      else
        child
      end
    end)
  end
end
