# frozen_string_literal: true

module Api
  class CommentsController < BaseController
    before_action :set_card
    before_action :set_comment, only: [ :show, :update, :destroy ]

    # GET /api/cards/:card_id/comments
    def index
      @comments = @card.comments.chronologically
      render json: @comments.map { |comment| comment_json(comment) }
    end

    # GET /api/cards/:card_id/comments/:id
    def show
      render json: comment_json(@comment)
    end

    # POST /api/cards/:card_id/comments
    def create
      @comment = @card.comments.create!(process_comment_params.merge(creator: Current.user))
      render json: comment_json(@comment), status: :created
    end

    # PATCH/PUT /api/cards/:card_id/comments/:id
    def update
      @comment.update!(process_comment_params)
      render json: comment_json(@comment)
    end

    # DELETE /api/cards/:card_id/comments/:id
    def destroy
      @comment.destroy!
      render json: { success: true, message: "Comment deleted" }
    end

    private

    def set_card
      @card = Card.find(params[:card_id])
    end

    def set_comment
      @comment = @card.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:body)
    end

    # Convert markdown body to HTML on write
    def process_comment_params
      permitted = comment_params
      if permitted[:body].present?
        permitted[:body] = MarkdownConverter.to_html(permitted[:body])
      end
      permitted
    end

    def comment_json(comment)
      {
        id: comment.id,
        card_id: comment.card_id,
        body: format_body(comment),
        creator_id: comment.creator_id,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end

    # Return markdown if Accept: text/markdown, otherwise HTML
    def format_body(comment)
      html_content = comment.body.to_s

      if request.headers["Accept"]&.include?("text/markdown")
        MarkdownConverter.to_markdown(html_content)
      else
        html_content
      end
    end
  end
end
