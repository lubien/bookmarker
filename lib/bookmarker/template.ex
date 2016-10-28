defmodule Bookmarker.Template do
  def render(bookmarks, config) do
    """
    # #{config.title}

    > #{config.description}
    #{maybe_render_timestamp(config.timestamp?)}
    #{render_bookmarks Map.get(bookmarks, "children", [])}
    """
  end

  def maybe_render_timestamp(timestamp?) do
    if timestamp? do
      {{year, month, day}, {hour, minute, _}} = :calendar.universal_time

      """
      > At #{month}/#{day}/#{year} #{hour}:#{minute}
      """
    else
      ""
    end
  end

  def render_bookmarks(bookmarks) do
    render_bookmarks(bookmarks, 2)
  end

  defp render_bookmarks([], _level), do: ""
  defp render_bookmarks(bookmarks, level) do
    bookmarks
    |> Stream.flat_map(fn
        %{ "type" => "folder" } = bookmark ->
          [
            bookmark["name"] |> render_header(level),
            Map.get(bookmark, "children", []) |> render_bookmarks(level + 1)
          ]

        bookmark ->
          ["* [#{bookmark["name"]}](#{bookmark["url"]})"]
    end)
    |> Enum.join("\n\n")
  end

  def render_header(title, level)
  when level < 6 do
    String.duplicate("#", level) <> " " <> title
  end
  def render_header(title, _level) do
    String.duplicate("#", 6) <> " " <> title
  end
end
