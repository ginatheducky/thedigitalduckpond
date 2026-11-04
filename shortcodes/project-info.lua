-- Convert metadata to plain text and escape it for HTML.
local function escape_html(value)
  local text = value == nil and "" or pandoc.utils.stringify(value)

  return text
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")
end

-- Keep icon class names restricted to a simple Bootstrap icon name.
local function make_icon(value)
  local name = value == nil and "" or pandoc.utils.stringify(value)

  if not name:match("^[a-z0-9%-]+$") then
    name = "star"
  end

  return string.format(
    '<i class="bi bi-%s fs-2 lh-1" aria-hidden="true"></i>',
    name
  )
end

-- These labels, icons, and their order are shared by every project.
local detail_fields = {
  { key = "components",      label = "Components",      icon = "layers" },
  { key = "material",        label = "Material",        icon = "box" },
  { key = "supports",        label = "Supports",        icon = "printer" },
  { key = "other-materials", label = "Other materials", icon = "tools" },
  { key = "assembly",        label = "Assembly",        icon = "gear" }
}

return {
  ["project-info"] = function(args, kwargs, meta)
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

    local project_id = text(meta["project-id"])

    if project_id ~= "" then
      html[#html + 1] = string.format([[
        <li class="d-flex align-items-center gap-2">
          <i class="bi bi-leaf fs-4 text-warning" aria-hidden="true"></i>
          <span class="visually-hidden">Project ID:</span>
          <strong>%s</strong>
        </li>
      ]], escape_html(project_id))
    end

    local version = text(meta.version)

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

    local status = text(meta.status)

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
      ]], style.icon, style.color, escape_html(style.label)))
    end

    if text(meta.date) ~= "" then
      add_item(string.format([[
        <i class="bi bi-calendar3 fs-4" aria-hidden="true"></i>
        <span>Published: %s</span>
      ]], escape_html(display_date(meta.date))))
    end

    if text(meta["updated-on"]) ~= "" then
      add_item(string.format([[
        <i class="bi bi-clock-history fs-4" aria-hidden="true"></i>
        <span>Updated: %s</span>
      ]], escape_html(display_date(meta["updated-on"]))))
    end

    html[#html + 1] = "</ul>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,


  ["project-highlights"] = function(args, kwargs, meta)
    local highlights = meta["project-highlights"]

    if not highlights or #highlights == 0 then
      return pandoc.Null()
    end

    local html = {
        '<ul class="d-flex flex-nowrap list-unstyled my-4" aria-label="Project highlights">'
    }

    for _, item in ipairs(highlights) do
      html[#html + 1] = string.format([[
        <li class="w-25 flex-shrink-0 px-2">
            <div class="d-flex flex-column align-items-center gap-2 text-center">
            <span class="d-inline-flex align-items-center justify-content-center bg-warning-subtle rounded-4 p-3">
                %s
            </span>
            <span class="lh-sm">%s</span>
            </div>
        </li>
      ]], make_icon(item.icon), escape_html(item.text))
    end

    html[#html + 1] = "</ul>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,

  ["project-details"] = function(args, kwargs, meta)
    local details = meta["project-details"] or {}
    local html = { '<dl class="d-flex flex-column gap-3 my-3">' }

    for _, field in ipairs(detail_fields) do
        local value = details[field.key]

        if value == nil or pandoc.utils.stringify(value) == "" then
        value = "Not specified"
        end

        html[#html + 1] = string.format([[
        <div class="d-flex align-items-start gap-3">
            <dt class="flex-shrink-0 fw-normal">
            %s
            <span class="visually-hidden">%s</span>
            </dt>
            <dd class="mb-0">
            <span class="fw-bold" aria-hidden="true">%s:</span>
            %s
            </dd>
        </div>
        ]],
        make_icon(field.icon),
        escape_html(field.label),
        escape_html(field.label),
        escape_html(value)
        )
    end

    html[#html + 1] = "</dl>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end
}