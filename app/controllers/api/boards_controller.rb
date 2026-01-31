# frozen_string_literal: true

module Api
  class BoardsController < BaseController
    before_action :set_board, only: :show

    # GET /api/boards
    def index
      @boards = Board.alphabetically
      render json: @boards.map { |board| board_json(board) }
    end

    # GET /api/boards/:id
    def show
      render json: board_json(@board, include_cards: true)
    end

    private

    def set_board
      @board = Board.find(params[:id])
    end

    def board_json(board, include_cards: false)
      json = {
        id: board.id,
        name: board.name,
        created_at: board.created_at,
        updated_at: board.updated_at
      }

      if include_cards
        json[:cards] = board.cards.published.latest.map { |card| card_json(card) }
      end

      json
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
