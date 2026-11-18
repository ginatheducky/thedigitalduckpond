-- Convert metadata to plain text and escape it for HTML.
local function escape_html(value)
  local text = value == nil and "" or pandoc.utils.stringify(value)

  return text
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")
end

return {
    ["project-banner"] = function(args, kwargs, meta)
    local function text(value)
      return value == nil and "" or pandoc.utils.stringify(value)
    end

    -- Format your existing MM/DD/YYYY dates for display.
    local function display_date(value)
      local raw = text(value)
      local month, day, year = raw:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")

      local months = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      }

      if month and months[tonumber(month)] then
        return string.format(
          "%s %d, %s",
          months[tonumber(month)],
          tonumber(day),
          year
        )
      end

      return raw
    end

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
      -- Add the v prefix only if it is not already present.
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

      local style = status_styles[status:lower()] or {
        label = status,
        icon = "info-circle",
        color = "text-bg-secondary"
      }

      add_item(string.format([[
        <i class="bi bi-%s fs-4" aria-hidden="true"></i>
        <span>Status:</span>
        <span class="badge rounded-pill %s fs-6">%s</span>
      ]], style["icon"], style["color"], escape_html(style["label"])))
    end

    if text(meta["date"]) ~= "" then
      add_item(string.format([[
        <i class="bi bi-calendar3 fs-4" aria-hidden="true"></i>
        <span>Published: %s</span>
      ]], escape_html(display_date(meta["date"]))))
    end

    if text(meta["updated"]) ~= "" then
      add_item(string.format([[
        <i class="bi bi-clock-history fs-4" aria-hidden="true"></i>
        <span>Updated: %s</span>
      ]], escape_html(display_date(meta["updated"]))))
    end

    html[#html + 1] = "</ul>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}