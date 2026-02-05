# frozen_string_literal: true

require "test_helper"

class MarkdownConverterTest < ActiveSupport::TestCase
  test "converts markdown to HTML" do
    markdown = "# Hello World\n\nThis is **bold** and *italic*."

    html = MarkdownConverter.to_html(markdown)

    assert_includes html, "<h1>Hello World</h1>"
    assert_includes html, "<strong>bold</strong>"
    assert_includes html, "<em>italic</em>"
  end

  test "converts fenced code blocks" do
    markdown = "```ruby\nputs 'hello'\n```"

    html = MarkdownConverter.to_html(markdown)

    assert_includes html, "<code"
    assert_includes html, "puts"
  end

  test "converts lists" do
    markdown = "- Item 1\n- Item 2\n- Item 3"

    html = MarkdownConverter.to_html(markdown)

    assert_includes html, "<ul>"
    assert_includes html, "<li>"
  end

  test "converts HTML to markdown" do
    html = "<h1>Hello World</h1><p>This is <strong>bold</strong> and <em>italic</em>.</p>"

    markdown = MarkdownConverter.to_markdown(html)

    assert_includes markdown, "# Hello World"
    assert_includes markdown, "**bold**"
    assert_includes markdown, "*italic*"
  end

  test "handles empty input for to_html" do
    assert_equal "", MarkdownConverter.to_html(nil)
    assert_equal "", MarkdownConverter.to_html("")
  end

  test "handles empty input for to_markdown" do
    assert_equal "", MarkdownConverter.to_markdown(nil)
    assert_equal "", MarkdownConverter.to_markdown("")
  end

  test "round-trips markdown through HTML and back" do
    original = "## Heading\n\nSome **bold** text with a [link](https://example.com)."

    html = MarkdownConverter.to_html(original)
    recovered = MarkdownConverter.to_markdown(html)

    # Won't be identical but should preserve key elements
    assert_includes recovered, "Heading"
    assert_includes recovered, "**bold**"
    assert_includes recovered, "link"
  end
end
