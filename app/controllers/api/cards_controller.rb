# frozen_string_literal: true

module Api
  class CardsController < BaseController
    before_action :set_board

    # GET /api/boards/:board_id/cards
    def index
      @cards = @board.cards.published.latest
      render json: @cards.map { |card| card_json(card) }
    end

    # POST /api/boards/:board_id/cards
    def create
      system_user = User.find_by(role: "system") || User.first
      Current.user = system_user  # Set Current.user for event tracking
      @card = @board.cards.create!(card_params.merge(status: "published", creator: system_user))
      render json: card_json(@card), status: :created
    end

    private

    def set_board
      @board = Board.find(params[:board_id])
    end

    def card_params
      params.require(:card).permit(:title, :description, :priority)
    end

    def card_json(card)
      {
        id: card.id,
        number: card.number,
        title: card.title,
        description: card.description.to_plain_text,
        status: card.status,
        created_at: card.created_at,
        updated_at: card.updated_at
      }
    end
  end
end
