# frozen_string_literal: true

class MarkdownConverter
  class << self
    # Convert Markdown to HTML
    def to_html(markdown)
      return "" if markdown.blank?

      renderer = Redcarpet::Render::HTML.new(
        hard_wrap: true,
        link_attributes: { target: "_blank", rel: "noopener" }
      )

      markdown_parser = Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        superscript: true,
        underline: true,
        highlight: true,
        no_intra_emphasis: true
      )

      markdown_parser.render(markdown)
    end

    # Convert HTML to Markdown
    def to_markdown(html)
      return "" if html.blank?

      ReverseMarkdown.convert(
        html,
        unknown_tags: :pass_through,
        github_flavored: true
      )
    end
  end
end
