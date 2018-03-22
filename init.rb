require_dependency '../../plugins/project_state/app/helpers/project_state_settings_helper'

Redmine::Plugin.register :project_state do
  name 'Project State plugin'
  author 'Default Value'
  description 'Plugin provides functionality to track the project current state with the ability to set the color per issue status'
  version '1.0'
  author_url 'http://default-value.com/'
  url 'https://github.com/DefaultValue/redmine-project-state'

  menu :project_menu, :state, { :controller => 'state', :action => 'index' }, :caption => :project_menu_state

  permission :state, :state => :index

  settings \
    :partial => 'settings/project_state_settings'
end

ActionDispatch::Reloader.to_prepare do
  SettingsHelper.send :include, ProjectStateSettingsHelper
end
