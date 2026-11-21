-- Convert a Pandoc metadata value to plain text.
local function text(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end

-- Escape characters that have a special meaning in HTML.
-- Escape & first so it doesn't affect the replacements below.
local function escape_html(value)
  return (value
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;"))
end

-- Every project uses these labels, icons, and row order.
-- Each key matches a field inside project-details in projects.yml.
local detail_fields = {
  { key = "components",      label = "Components",      icon = "layers" },
  { key = "material",        label = "Material",        icon = "box" },
  { key = "supports",        label = "Supports",        icon = "printer" },
  { key = "other-materials", label = "Other materials", icon = "tools" },
  { key = "assembly",        label = "Assembly",        icon = "gear" }
}

return {
  ["project-details"] = function(args, kwargs, meta)
    -- Quarto loads data/projects.yml into meta.projects.
    -- A page with project-id: MS selects projects["MS"].
    local project_id = text(meta["project-id"])
    local projects = assert(meta.projects, "Missing projects metadata")
    local project = assert(
      projects[project_id],
      "Unknown or missing project-id: " .. project_id
    )

    -- Use an empty table if the project has no details yet.
    local details = project["project-details"] or {}
    local html = { '<dl class="d-flex flex-column gap-3 my-3">' }

    -- Build one description-list row per field in the order above.
    for _, field in ipairs(detail_fields) do
      local value = text(details[field.key])
      if value == "" then
        value = "Not specified"
      end

      local label = escape_html(field.label)

      -- The icon is decorative. Screen readers get the label from <dt>.
      html[#html + 1] = string.format([[
        <div class="d-flex align-items-start gap-3">
          <dt class="flex-shrink-0 fw-normal">
            <i class="bi bi-%s fs-2 lh-1" aria-hidden="true"></i>
            <span class="visually-hidden">%s</span>
          </dt>
          <dd class="mb-0">
            <span class="fw-bold" aria-hidden="true">%s:</span>
            %s
          </dd>
        </div>
      ]], field.icon, label, label, escape_html(value))
    end

    -- Insert the completed HTML where {{< project-details >}} appears.
    html[#html + 1] = "</dl>"
    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end
}