-- Convert a Pandoc metadata value to plain text.
-- Use an empty string for missing values so their items can be omitted.
local function text(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end

-- Escape text before inserting it into HTML.
-- Escape & first so the replacements below keep their meaning.
local function escape_html(value)
  return (value
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;"))
end

-- Set the label, icon, and badge color for each known status.
local status_styles = {
  ["finished"] = {
    label = "finished",
    icon = "circle-check",
    color = "text-bg-success"
  },
  ["ongoing"] = {
    label = "ongoing",
    icon = "gears",
    color = "text-bg-warning"
  },
  ["planned"] = {
    label = "planned",
    icon = "clipboard-question",
    color = "text-bg-secondary"
  },
  ["revision"] = {
    label = "revision",
    icon = "rotate",
    color = "text-bg-secondary"
  }
}

return {
  ["project-info-banner"] = function(args, kwargs, meta)
    -- Quarto loads data/projects.yml into meta.projects.
    -- For example, project-id: MS selects projects["MS"].
    local lookup_id = text(meta["project-id"])
    local projects = assert(meta.projects, "Missing projects metadata")
    local project = assert(
      projects[lookup_id],
      "Unknown or missing project-id: " .. lookup_id
    )

    -- Take the slug, icon, version, and status from the shared record.
    local slug = text(project.slug)
    local project_icon = text(project.icon)
    local version = text(project.version)
    local status = text(project.status)

    -- Use the dates from this page's front matter.
    local published = text(meta.date)
    local updated = text(meta["date-modified"])

    local html = {
      '<ul class="d-flex flex-wrap align-items-center gap-3 list-unstyled py-3 mb-4" aria-label="Project information">'
    }

    -- Append an item with the standard spacing and a left divider.
    local function add_item(content)
      html[#html + 1] =
        '<li class="d-flex align-items-center gap-2 border-start ps-3">'
        .. content
        .. '</li>'
    end

    -- A Bootstrap icon name can contain lowercase letters, digits,
    -- and hyphens. Use the leaf icon if the name is missing or invalid.
    if not project_icon:match("^[a-z0-9%-]+$") then
      project_icon = "circle-question"
    end

    -- The first item shows the slug beside the icon without a divider.
    if slug ~= "" then
      html[#html + 1] = string.format([[
        <li class="d-flex align-items-center gap-2">
          <i class="fa-solid fa-%s fs-4 text-warning" aria-hidden="true"></i>
          <strong>%s</strong>
        </li>
      ]], project_icon, escape_html(slug))
    end

    if version ~= "" then
      -- Add the v prefix only when the version has no prefix yet.
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

    if status ~= "" then
      -- Match known statuses regardless of case and give other statuses
      -- a neutral badge with their original text.
      local style = status_styles[status:lower()] or {
        label = status,
        icon = "circle-question",
        color = "text-bg-secondary"
      }

      add_item(string.format([[
        <i class="fa-solid fa-%s fs-4" aria-hidden="true"></i>
        <span>Status:</span>
        <span class="badge rounded-pill %s fs-6">%s</span>
      ]], style.icon, style.color, escape_html(style.label)))
    end

    if published ~= "" then
      add_item(string.format([[
        <i class="fa-solid fa-calendar-plus fs-4" aria-hidden="true"></i>
        <span>Published: %s</span>
      ]], escape_html(published)))
    end

    if updated ~= "" then
      add_item(string.format([[
        <i class="fa-solid fa-calendar-check fs-4" aria-hidden="true"></i>
        <span>Updated: %s</span>
      ]], escape_html(updated)))
    end

    -- Join the HTML fragments and insert them where the shortcode appears.
    html[#html + 1] = "</ul>"
    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}