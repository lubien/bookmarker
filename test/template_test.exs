defmodule TemplateTest do
  use ExUnit.Case

  import Bookmarker.Template, only: [ render: 2,
                                      render_header: 2 ]

  @url "http://example.com"

  test "renders the template" do
    config = %{ title: "Foo", description: "Bar", timestamp?: false}
    assert render(%{"children" => []}, config) ==
      """
      # Foo

      > Bar


      """

    assert render(%{
      "children" => [
        %{
          "name" => "A",
          "url" => @url
        },
        %{
          "name" => "B",
          "url" => @url
        }
      ]
    }, config) ==
      """
      # Foo

      > Bar

      * [A](#{@url})

      * [B](#{@url})
      """

    assert render(%{
      "children" => [
        %{
          "name" => "A",
          "type" => "folder",
          "children" => [
            %{
              "name" => "C",
              "url" => @url
            }
          ]
        },
        %{
          "name" => "B",
          "url" => @url
        }
      ]
    }, config) ==
      """
      # Foo

      > Bar

      ## A

      * [C](#{@url})

      * [B](#{@url})
      """
  end

  test "rendering headers" do
    assert render_header("Foo", 3) == "### Foo"
    assert render_header("Foo", 10) == "###### Foo"
  end
end
