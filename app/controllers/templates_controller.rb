class TemplatesController < ApplicationController
  before_action :set_template, only: [:edit, :update, :destroy]
  before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @page = params[:page] || 1
    @templates = Template.where(is_deleted: false).page(@page).per(10)
  end

  def new
    @template = Template.new
  end

  def create
    @template = Template.new(template_params)
    @template.added_by = current_user
    if @template.save
      redirect_to templates_path, notice: 'Template was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @template.edited_by = current_user
    if @template.update(template_params)
      redirect_to templates_path, notice: 'Template was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.deleted_by = current_user
    @template.is_deleted = true
    if @template.save
      redirect_to templates_path, notice: 'Template was successfully deleted.'
    else
      redirect_to templates_path, alert: 'Failed to delete template.'
    end
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:name, :meta_template_name, :language, :component)
  end
end
