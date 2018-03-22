module ProjectStateSettingsHelper

  def all_issue_statuses
    allStatuses = IssueStatus.all.sorted
  end


  def color_from_status(status_name)
    status_name_prepared = status_name.parameterize.underscore
    (Setting.plugin_project_state && Setting.plugin_project_state.include?(status_name_prepared)) ? Setting.plugin_project_state[status_name_prepared] : ''
  end

end
