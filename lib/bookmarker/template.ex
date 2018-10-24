defmodule Bookmarker.Template do
  def render(bookmarks, config) do
    """
    # #{config.title}

    > #{config.description}
    #{maybe_render_timestamp config.timestamp?}
    #{render_bookmarks Map.get(bookmarks, "children", [])}
    """
  end

  def maybe_render_timestamp(false), do: ""
  def maybe_render_timestamp(_timestamp?) do
    {{year, month, day}, {hour, minute, _}} = :calendar.local_time
    timestamp = render_timestamp(hour, minute)

    """
    > At #{month}/#{day}/#{year} #{timestamp}
    """
  end
  
  defp render_timestamp(hour, minute) do
    hour_with_padding = 
      hour 
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
    minute_with_padding = 
      minute
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
    "#{hour_with_padding}:#{minute_with_padding}"
  end

  def render_bookmarks(bookmarks) do
    render_bookmarks(bookmarks, 2)
  end

  defp render_bookmarks([], _level), do: ""
  defp render_bookmarks(bookmarks, level) do
    bookmarks
    |> Stream.flat_map(&render_bookmark(&1, level))
    |> Enum.join("\n\n")
  end

  def render_bookmark(%{ "type" => "folder", "name" => name, "children" => children  }, level) do
    [
      render_header(name, level),
      render_bookmarks(children, level + 1)
    ]
  end
  def render_bookmark(%{ "name" => name, "url" => url }, _level) do
    ["* [#{name}](#{url})"]
  end

  def render_header(title, level)
  when level < 6 do
    String.duplicate("#", level) <> " " <> title
  end
  def render_header(title, _level) do
    String.duplicate("#", 6) <> " " <> title
  end
end
