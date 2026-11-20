local function text(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end

local function escape_html(value)
  return (value
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;"))
end

local status_styles = {
  ["finished"] = {
    label = "Finished",
    icon = "check-circle",
    color = "text-bg-success"
  },
  ["in development"] = {
    label = "In development",
    icon = "tools",
    color = "text-bg-warning"
  },
  ["planned"] = {
    label = "Planned",
    icon = "lightbulb",
    color = "text-bg-secondary"
  }
}

return {
  ["project-banner"] = function(args, kwargs, meta)
    local html = {
      '<ul class="d-flex flex-wrap align-items-center gap-3 list-unstyled py-3 mb-4" aria-label="Project information">'
    }

    local function add_item(content)
      html[#html + 1] =
        '<li class="d-flex align-items-center gap-2 border-start ps-3">'
        .. content
        .. '</li>'
    end

    local banner = meta["project-banner"] or {}
    local project_id = text(banner["project-id"])
    local project_icon = text(banner["project-icon"])

    if not project_icon:match("^[a-z0-9%-]+$") then
      project_icon = "leaf"
    end

    if project_id ~= "" then
      html[#html + 1] = string.format([[
        <li class="d-flex align-items-center gap-2">
          <i class="bi bi-%s fs-4 text-warning" aria-hidden="true"></i>
          <span class="visually-hidden">Project ID:</span>
          <strong>%s</strong>
        </li>
      ]], project_icon, escape_html(project_id))
    end

    local version = text(banner["version"])

    if version ~= "" then
      if not version:match("^[vV]") then
        version = "v" .. version
      end

      add_item(string.format([[
        <span class="visually-hidden">Version:</span>
        <span class="badge rounded-pill bg-warning-subtle border border-warning text-body fs-6">
          %s
        </span>
      ]], escape_html(version)))
    end

    local status = text(banner["status"])

    if status ~= "" then
      local style = status_styles[status:lower()] or {
        label = status,
        icon = "info-circle",
        color = "text-bg-secondary"
      }

      add_item(string.format([[
        <i class="bi bi-%s fs-4" aria-hidden="true"></i>
        <span>Status:</span>
        <span class="badge rounded-pill %s fs-6">%s</span>
      ]], style.icon, style.color, escape_html(style.label)))
    end

    local published = text(meta["date"])
    local updated = text(meta["date-modified"])

    if published ~= "" then
      add_item(string.format([[
        <i class="bi bi-calendar3 fs-4" aria-hidden="true"></i>
        <span>Published: %s</span>
      ]], escape_html(published)))
    end

    if updated ~= "" then
      add_item(string.format([[
        <i class="bi bi-clock-history fs-4" aria-hidden="true"></i>
        <span>Updated: %s</span>
      ]], escape_html(updated)))
    end

    html[#html + 1] = "</ul>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}