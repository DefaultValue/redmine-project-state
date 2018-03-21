# Project State Redmine plugin

Plugin provides functionality for viewing project state with colored status rows.

## Installation

1. Clone this plugin to your Redmine plugins directory:

```bash
user@user:/path/to/redmine/plugins$ git clone git@github.com:DefaultValue/redmine-project-state.git project_state
```

2. Restart Redmine to check plugin availability and configure its options.
                                                                                        
3. Go to plugin configuration page (Administration > Plugins > Daily Workload Management plugin > Configure) and set colors for issue statuses.
For instance:

- New #FFFFFF
- In Progress #FFFF41
- Resolved #24FF40
- Closed #24FF40
- Rejected #69A857
- Clarification needed #FF9927
- Could not reproduce #91C481
- Wouldn’t fix #EA9798
- Reopened #26FFFF
- Ready for testing #A2C0F1
- On Hold #C1799D
- Merge request #F1C245
- Blocked #E69043

## Usage

1. Go to project 'State' page ('Projects' > 'Your project' > 'State') to track project state.