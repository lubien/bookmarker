defmodule BookmarkTest do
  use ExUnit.Case

  import Bookmarker.Bookmark, only: [drop_at: 2]

  @fixture %{
    "name" => "Other bookmarks",
    "children" => [
      %{
        "name" => "A",
        "children" => [
          %{
            "name" => "B",
            "children" => [
              %{
                "name" => "C"
              }
            ]
          }
        ]
      }
    ]
  }

  test "can filter folders" do
    assert drop_at(@fixture, ["A"]) == %{
             "name" => "Other bookmarks",
             "children" => []
           }

    assert drop_at(@fixture, ["A", "B"]) == %{
             "name" => "Other bookmarks",
             "children" => [
               %{
                 "name" => "A",
                 "children" => []
               }
             ]
           }
  end
end
