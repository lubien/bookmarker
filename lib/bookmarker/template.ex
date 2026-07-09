defmodule Bookmarker.Template do
  @self_closing_tag_regex ~r/<[^>]*\/>/
  @opening_tag_regex ~r/<[^\/][^>]*>/
  @closing_tag_regex ~r/<\/[^>]*>/

  def render(bookmarks, config) do
    separator = if Map.get(config, :double_space?, false), do: "\n\n", else: "\n"
    strip_html? = Map.get(config, :strip_html?, false)

    """
    # #{config.title}

    > #{config.description}
    #{maybe_render_timestamp(config.timestamp?)}
    #{render_bookmarks(Map.get(bookmarks, "children", []), separator, strip_html?)}
    """
  end

  def maybe_render_timestamp(false), do: ""

  def maybe_render_timestamp(_timestamp?) do
    {{year, month, day}, {hour, minute, _}} = :calendar.local_time()
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

  def render_bookmarks(bookmarks, separator \\ "\n", strip_html? \\ false) do
    render_bookmarks(bookmarks, 2, separator, strip_html?)
  end

  defp render_bookmarks([], _level, _separator, _strip_html?), do: ""

  defp render_bookmarks(bookmarks, level, separator, strip_html?) do
    bookmarks
    |> Stream.flat_map(&render_bookmark(&1, level, separator, strip_html?))
    |> Enum.join(separator)
  end

  def render_bookmark(
        %{"type" => "folder", "name" => name, "children" => children},
        level,
        separator,
        strip_html?
      ) do
    [
      render_header(maybe_strip_html(name, strip_html?), level),
      render_bookmarks(children, level + 1, separator, strip_html?)
    ]
  end

  def render_bookmark(%{"name" => name, "url" => url}, _level, _separator, strip_html?) do
    ["* [#{maybe_strip_html(name, strip_html?)}](#{url})"]
  end

  defp maybe_strip_html(name, false), do: name

  defp maybe_strip_html(name, true) do
    name
    |> String.replace(@self_closing_tag_regex, "")
    |> String.replace(@closing_tag_regex, ")")
    |> String.replace(@opening_tag_regex, "(")
  end

  def render_header(title, level)
      when level < 6 do
    String.duplicate("#", level) <> " " <> title
  end

  def render_header(title, _level) do
    String.duplicate("#", 6) <> " " <> title
  end
end
