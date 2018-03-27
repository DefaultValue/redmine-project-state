class StateTempAccessController < ApplicationController
  default_search_scope :issues

  layout 'temp_access_base'

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

  def index
    project_temp_link = ProjectTempLink.where(url_hash: params[:hash]).first
    project_id        = project_temp_link ? project_temp_link.project_id : nil
    @project          = Project.find(project_id)

    retrieve_query

    if @query.valid?
      respond_to do |format|
        format.html {
          @issue_count = @query.annon_issue_count
          @issue_pages = Paginator.new @issue_count, custom_per_page_option, params['page']
          @issues = @query.annon_issues(:order => "fixed_version_id DESC, priority_id DESC",:offset => @issue_pages.offset, :limit => @issue_pages.per_page)
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

  def custom_per_page_option
    if params[:per_page] && Setting.per_page_options_array.include?(params[:per_page].to_s.to_i)
      per_page = params[:per_page].to_s.to_i
      session[:per_page] = per_page
    elsif session[:per_page]
      per_page = session[:per_page]
    else
      per_page = 1000
    end
    per_page
  end

end
