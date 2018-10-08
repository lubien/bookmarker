defmodule Bookmarker.Bookmark do
  def drop_at(bookmarks, []), do: bookmarks

  def drop_at(bookmarks, [dir | []]) do
    bookmarks
    |> Map.update("children", [], fn children ->
      Enum.filter children, fn child -> child["name"] != dir end
    end)
  end

  def drop_at(bookmarks, [dir | tail]) do
    bookmarks
    |> Map.update("children", [], fn children ->
      Enum.map(children, fn child ->
        if child["name"] == dir do
          drop_at child, tail
        else
          child
        end
      end)
    end)
  end

  def get_at(bookmarks, nil), do: bookmarks

  def get_at(bookmarks, dir) do
    bookmarks
    |> Map.update("children", [], fn children ->
      Enum.filter children, fn child -> child["name"] == dir end
    end)
  end
end
