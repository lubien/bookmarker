defmodule CliTest do
  use ExUnit.Case

  import Bookmarker.CLI, only: [parse_args: 1, build_config: 1]

  test "parsing args" do
    assert parse_args(["-h"]) == [help: true]
    assert parse_args(["--help"]) == [help: true]

    assert parse_args(["-f", "foo.json"]) == [file: "foo.json"]
    assert parse_args(["--file", "foo.json"]) == [file: "foo.json"]

    assert parse_args(["-t", "Foo"]) == [title: "Foo"]
    assert parse_args(["--title", "Foo"]) == [title: "Foo"]

    assert parse_args(["-d", "Bar"]) == [description: "Bar"]
    assert parse_args(["--description", "Bar"]) == [description: "Bar"]

    assert parse_args(["-i", "A/B"]) == [ignore: "A/B"]
    assert parse_args(["--ignore", "A/B"]) == [ignore: "A/B"]

    assert parse_args(["-o", "out.md"]) == [output: "out.md"]
    assert parse_args(["--output", "out.md"]) == [output: "out.md"]
  end

  test "config building" do
    assert Map.get(build_config(file: "fo.json"), :file) == "fo.json"
    assert Map.get(build_config(title: "Foo"), :title) == "Foo"
    assert Map.get(build_config(description: "Bar"), :description) == "Bar"
    assert Map.get(build_config(ignore: "Foo", ignore: "Bar"), :ignore) == ["Foo", "Bar"]
    assert Map.get(build_config(output: "fo.md"), :output) == "fo.md"
  end
end
