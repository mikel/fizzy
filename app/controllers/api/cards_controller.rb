# frozen_string_literal: true

module Api
  class CardsController < BaseController
    before_action :set_board, only: [ :index, :create ]
    before_action :set_card, only: [ :show, :update ]

    # GET /api/boards/:board_id/cards
    def index
      @cards = @board.cards.published.latest
      render json: @cards.map { |card| card_json(card) }
    end

    # GET /api/cards/:id
    def show
      render json: card_json(@card)
    end

    # POST /api/boards/:board_id/cards
    def create
      system_user = User.find_by(role: "system") || User.first
      Current.user = system_user
      @card = @board.cards.create!(processed_card_params.merge(status: "published", creator: system_user))
      render json: card_json(@card), status: :created
    end

    # PATCH/PUT /api/cards/:id
    def update
      system_user = User.find_by(role: "system") || User.first
      Current.user = system_user
      @card.update!(processed_card_params)
      render json: card_json(@card)
    end

    private

    def set_board
      @board = Board.find(params[:board_id])
    end

    def set_card
      @card = Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(:title, :description, :priority)
    end

    # Convert markdown description to HTML on write
    def processed_card_params
      permitted = card_params
      if permitted[:description].present?
        permitted[:description] = MarkdownConverter.to_html(permitted[:description])
      end
      permitted
    end

    def card_json(card)
      {
        id: card.id,
        number: card.number,
        title: card.title,
        description: format_description(card),
        status: card.status,
        created_at: card.created_at,
        updated_at: card.updated_at
      }
    end

    # Return markdown if Accept: text/markdown, otherwise HTML
    def format_description(card)
      html_content = card.description.to_s

      if request.headers["Accept"]&.include?("text/markdown")
        MarkdownConverter.to_markdown(html_content)
      else
        html_content
      end
    end
  end
end
