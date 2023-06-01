class IssueCausesController < ApplicationController

  menu_item :issue_causes

  before_action :authorize_global
  before_action :find_issue_cause, only: [:show, :edit, :update]
  before_action :find_issue_causes, only: [:context_menu, :bulk_edit, :bulk_update, :destroy]

  helper :issue_causes
  helper :custom_fields, :context_menus, :attachments, :issues
  include_query_helpers

  accept_api_auth :index, :show, :create, :update, :destroy

  def index

    retrieve_query(IssueCauseQuery)
    @entity_count = @query.issue_causes.count
    @entity_pages = Paginator.new @entity_count, per_page_option, params['page']
    @entities = @query.issue_causes(offset: @entity_pages.offset, limit: @entity_pages.per_page)

  end

  def show
    respond_to do |format|
      format.html
      format.api
      format.js
    end
  end

  def new
    @issue_cause = IssueCause.new
    @issue_cause.safe_attributes = params[:issue_cause]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @issue_cause = IssueCause.new 
    @issue_cause.safe_attributes = params[:issue_cause]

    respond_to do |format|
      if @issue_cause.save
        format.html do
          flash[:notice] = l(:notice_successful_create)
          redirect_back_or_default issue_cause_path(@issue_cause)
        end
        format.api { render action: 'show', status: :created, location: issue_cause_url(@issue_cause) }
        format.js { render template: 'common/close_modal' }
      else
        format.html { render action: 'new' }
        format.api { render_validation_errors(@issue_cause) }
        format.js { render action: 'new' }
      end
    end
  end

  def edit
    @issue_cause.safe_attributes = params[:issue_cause]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @issue_cause.safe_attributes = params[:issue_cause]

    respond_to do |format|
      if @issue_cause.save
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default issue_cause_path(@issue_cause)
        end
        format.api { render_api_ok }
        format.js { render template: 'common/close_modal' }
      else
        format.html { render action: 'edit' }
        format.api { render_validation_errors(@issue_cause) }
        format.js { render action: 'edit' }
      end
    end
  end

  def destroy
    @issue_causes.each(&:destroy)

    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default issue_causes_path
      end
      format.api { render_api_ok }
    end
  end

  def bulk_edit
  end

  def bulk_update
    unsaved, saved = [], []
    attributes = parse_params_for_bulk_update(params[:issue_cause])
    @issue_causes.each do |entity|
      entity.init_journal(User.current) if entity.respond_to? :init_journal
      entity.safe_attributes = attributes
      if entity.save
        saved << entity
      else
        unsaved << entity
      end
    end
    respond_to do |format|
      format.html do
        if unsaved.blank?
          flash[:notice] = l(:notice_successful_update)
        else
          flash[:error] = unsaved.map{|i| i.errors.full_messages}.flatten.uniq.join(",\n")
        end
        redirect_back_or_default :index
      end
    end
  end

  def context_menu
    if @issue_causes.size == 1
      @issue_cause = @issue_causes.first
    end

    can_edit = @issue_causes.detect{|c| !c.editable?}.nil?
    can_delete = @issue_causes.detect{|c| !c.deletable?}.nil?
    @can = {edit: can_edit, delete: can_delete}
    @back = back_url

    @issue_cause_ids, @safe_attributes, @selected = [], [], {}
    @issue_causes.each do |e|
      @issue_cause_ids << e.id
      @safe_attributes.concat e.safe_attribute_names
      attributes = e.safe_attribute_names - (%w(custom_field_values custom_fields))
      attributes.each do |c|
        column_name = c.to_sym
        if @selected.key? column_name
          @selected[column_name] = nil if @selected[column_name] != e.send(column_name)
        else
          @selected[column_name] = e.send(column_name)
        end
      end
    end

    @safe_attributes.uniq!

    render layout: false
  end

  def autocomplete
  end

  private

  def find_issue_cause
    @issue_cause = IssueCause.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_issue_causes
    @issue_causes = IssueCause.visible.where(id: (params[:id] || params[:ids])).to_a
    @issue_cause = @issue_causes.first if @issue_causes.count == 1
    raise ActiveRecord::RecordNotFound if @issue_causes.empty?
    raise Unauthorized unless @issue_causes.all?(&:visible?)

    @projects = @issue_causes.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end


end
