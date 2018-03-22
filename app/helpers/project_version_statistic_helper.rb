module ProjectVersionStatisticHelper
  @versions = []

  def get_versions_time_statistic
    time_statistic = ActiveRecord::Base.connection.execute("
      SELECT
        IF(ISNULL(fixed_version_id), 0, fixed_version_id) as version_id,
        SUM(issues.estimated_hours) AS estimated_hours,
        SUM(prepared_time_entries.spent_hours) AS spent_hours
      FROM issues
        LEFT JOIN (SELECT
                     time_entries.issue_id   AS issue_id,
                     time_entries.project_id AS project_id,
                     SUM(time_entries.hours) AS spent_hours
                   FROM time_entries
                   WHERE time_entries.project_id = #{@project.id}
                   GROUP BY time_entries.issue_id) AS prepared_time_entries
         ON issues.id = prepared_time_entries.issue_id
      WHERE issues.project_id = #{@project.id}
      GROUP BY issues.fixed_version_id;
    ").to_a

    prepared_time_statistic = {}

    time_statistic.each do |item|
      prepared_time_statistic[item[0]] = [item[1], item[2]]
    end

    prepared_time_statistic
  end

  def prepare_version_row(issue)
    if @versions.nil?
      @versions = []
    end

    unless @versions.include? issue.fixed_version_id
      @versions.push(issue.fixed_version_id)

      time         = get_versions_time_statistic[issue.fixed_version_id.nil? ? 0 : issue.fixed_version_id]
      version_name = issue.fixed_version_id.nil? ? l(:no_version) : Version.find(issue.fixed_version_id).name

      return "<tr style='border-top: 1px solid; border-bottom: 1px solid;'>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th>#{version_name}</th>
          <th></th>
          <th>Total: #{time[0].to_f.round(2)}</th>
          <th>Total: #{time[1].to_f.round(2)}</th>
      </tr>"
    end
  end
end
