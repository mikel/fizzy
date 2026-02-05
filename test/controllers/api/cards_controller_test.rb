# frozen_string_literal: true

require "test_helper"

module Api
  class CardsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @board = boards(:one)
      @card = cards(:one)
    end

    test "create card converts markdown to HTML" do
      markdown_description = "# Hello\n\nThis is **bold** and *italic*"

      assert_difference -> { Card.count }, 1 do
        post api_board_cards_path(@board), params: {
          card: { title: "Test Card", description: markdown_description }
        }
      end

      assert_response :created
      card = Card.last
      # Description should be stored as HTML
      assert_includes card.description.to_s, "<h1>"
      assert_includes card.description.to_s, "<strong>bold</strong>"
      assert_includes card.description.to_s, "<em>italic</em>"
    end

    test "show card returns HTML by default" do
      get api_card_path(@card)

      assert_response :success
      json = @response.parsed_body
      # Should return HTML (or plain text from ActionText)
      assert json["description"].present?
    end

    test "show card returns markdown with Accept header" do
      # First set some HTML content
      @card.update!(description: "<h1>Title</h1><p>Some <strong>bold</strong> text</p>")

      get api_card_path(@card), headers: { "Accept" => "text/markdown" }

      assert_response :success
      json = @response.parsed_body
      description = json["description"]

      # Should be converted to markdown
      assert_includes description, "# Title"
      assert_includes description, "**bold**"
    end

    test "update card converts markdown to HTML" do
      markdown_description = "## Updated\n\n- Item 1\n- Item 2"

      patch api_card_path(@card), params: {
        card: { description: markdown_description }
      }

      assert_response :success
      @card.reload
      # Description should be stored as HTML
      assert_includes @card.description.to_s, "<h2>"
      assert_includes @card.description.to_s, "<li>"
    end

    test "index returns list of cards" do
      get api_board_cards_path(@board)

      assert_response :success
      json = @response.parsed_body
      assert json.is_a?(Array)
    end
  end
end
