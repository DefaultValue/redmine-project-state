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

  def plain_column_content(column, item)
    value = column.value_object(item)
    if value.is_a?(Array)
      values = value.collect {|v| column_value(column, item, v)}.compact
      safe_join(values, ', ')
    else
      plain_column_value(column, item, value)
    end
  end

  def plain_column_value(column, item, value)
    case column.name
      when :id
        value
      when :subject
        value
      when :parent
        value ? "##{value.id}" : ''
      when :description
        item.description? ? content_tag('div', textilizable(item, :description), :class => "wiki") : ''
      when :last_notes
        item.last_notes.present? ? content_tag('div', textilizable(item, :last_notes), :class => "wiki") : ''
      when :done_ratio
        progress_bar(value)
      when :relations
        content_tag('span',
                    value.to_s(item) {|other| link_to_issue(other, :subject => false, :tracker => false)}.html_safe,
                    :class => value.css_classes_for(item))
      when :hours, :estimated_hours
        format_hours(value)
      when :spent_hours
        format_hours(value)
      when :total_spent_hours
        format_hours(value)
      when :attachments
        value.to_a.map {|a| format_object(a)}.join(" ").html_safe
      else
        plain_format_object(value)
    end
  end

  # Helper that formats object for html or text rendering
  def plain_format_object(object, html=true, &block)
    if block_given?
      object = yield object
    end
    case object.class.name
      when 'Array'
        formatted_objects = object.map {|o| format_object(o, html)}
        html ? safe_join(formatted_objects, ', ') : formatted_objects.join(', ')
      when 'Time'
        format_time(object)
      when 'Date'
        format_date(object)
      when 'Fixnum'
        object.to_s
      when 'Float'
        sprintf "%.2f", object
      when 'User'
        object.to_s
      when 'Project'
        object.to_s
      when 'Version'
        object.to_s
      when 'TrueClass'
        l(:general_text_Yes)
      when 'FalseClass'
        l(:general_text_No)
      when 'Issue'
        "##{object.id}"
      when 'Attachment'
       object.filename
      when 'CustomValue', 'CustomFieldValue'
        if object.custom_field
          f = object.custom_field.format.formatted_custom_value(self, object, html)
          if f.nil? || f.is_a?(String)
            f
          else
            format_object(f, html, &block)
          end
        else
          object.value.to_s
        end
      else
        html ? h(object) : object.to_s
    end
  end

end
