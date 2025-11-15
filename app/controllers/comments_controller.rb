class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [ :destroy ]
  before_action :check_owner, only: [ :destroy ]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("comments_list", partial: "comments/comment", locals: { comment: @comment }),
            turbo_stream.replace("comment_form", partial: "comments/form", locals: { post: @post, comment: Comment.new }),
            turbo_stream.append("toast_container", partial: "shared/toast", locals: { message: t("comments.created"), type: "success" })
          ]
        }
        format.html {
          flash[:success] = t("comments.created")
          redirect_to @post
        }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { post: @post, comment: @comment })
        }
        format.html {
          flash.now[:danger] = t("comments.create_failed")
          redirect_to @post, status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    @comment.destroy!

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("comment_#{@comment.id}"),
          turbo_stream.append("toast_container", partial: "shared/toast", locals: { message: t("comments.destroyed"), type: "success" })
        ]
      }
      format.html {
        flash[:success] = t("comments.destroyed")
        redirect_to @post
      }
    end
  rescue => e
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.append("toast_container", partial: "shared/toast", locals: { message: t("comments.destroy_failed"), type: "error" })
      }
      format.html {
        flash[:alert] = t("comments.destroy_failed")
        redirect_to @post
      }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def check_owner
    unless @comment.user == current_user
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append("toast_container", partial: "shared/toast", locals: { message: t("comments.access_denied"), type: "error" })
        }
        format.html {
          redirect_to @post, alert: t("comments.access_denied")
        }
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
