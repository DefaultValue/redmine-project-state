require 'securerandom'

class StateController < ApplicationController
  default_search_scope :issues

  before_filter :find_project, :authorize, :only => :index

  include StateQueriesHelper
  include BoardsHelper
  include IssuesHelper
  include ProjectStateSettingsHelper
  include ProjectVersionStatisticHelper

  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :queries
  helper :repositories
  helper :timelog
  helper :issues
  helper :project_state_settings
  helper :project_version_statistic

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  end

  def index
    retrieve_query

    project_code = params[:id]
    link         = ProjectTempLink.find_by(:project_id => project_code)
    if link.nil?
      link            = ProjectTempLink.new
      link.project_id = project_code
      link.url_hash   = SecureRandom.uuid
      link.save
    end
    link.url_hash
    @temp_url = url_for :controller => 'state_temp_access', :action => 'index', :hash => link.url_hash

    if @query.valid?
      respond_to do |format|
        format.html {
          @issue_count = @query.issue_count
          @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
          @issues = @query.issues(:order => "fixed_version_id DESC, priority_id DESC",:offset => @issue_pages.offset, :limit => @issue_pages.per_page)
          render :layout => !request.xhr?
        }
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.any(:atom, :csv, :pdf) { head 422 }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
