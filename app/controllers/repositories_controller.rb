# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show toggle_star]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = policy_scope(Repository)
    @team_repositories = Repository
                         .joins(namespace: { team: :users })
                         .where("users.id = :user_id", user_id: current_user.id)
    @other_repositories = @repositories - @team_repositories
    @team_repositories_serialized = API::Entities::Repositories.represent(
      @team_repositories,
      current_user: current_user,
      type:         :internal
    ).to_json
    @other_repositories_serialized = API::Entities::Repositories.represent(
      @other_repositories,
      current_user: current_user,
      type:         :internal
    ).to_json
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    authorize @repository
    @tags = @repository.groupped_tags
    serialize_repository
    @repository_comments = @repository.comments.all
    @comments_serialized = API::Entities::Comments.represent(
      @repository.comments.all,
      current_user: current_user,
      type:         :internal
    ).to_json
    respond_with(@repository)
  end

  # POST /repositories/toggle_star
  def toggle_star
    respond_to do |format|
      if @repository.toggle_star(current_user)
        serialize_repository
        format.json { render json: @repository_serialized }
      else
        format.json { render json: @repository.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  protected

  def set_repository
    @repository = Repository.find(params[:id])
  end

  def serialize_repository
    @repository_serialized = API::Entities::Repositories.represent(
      @repository,
      current_user: current_user,
      type:         :internal
    ).to_json
  end
end
