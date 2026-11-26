-- Convert a Pandoc metadata value to plain text.
local function text(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end

-- Escape text before inserting it into HTML. Handle & first
-- so the entities added by the later replacements stay intact.
local function escape_html(value)
  return (text(value)
    :gsub("&", "&amp;")
    :gsub('"', "&quot;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;"))
end

-- Allow lowercase letters, digits, and hyphens in icon class names.
-- Use the star icon when the name is missing or has other characters.
local function make_icon(value)
  local name = text(value)

  if not name:match("^[a-z0-9%-]+$") then
    name = "star"
  end

  return string.format(
    '<i class="fa-solid fa-%s fs-2 lh-1" aria-hidden="true"></i>',
    name
  )
end

return {
  ["project-highlights"] = function(args, kwargs, meta)
    -- Quarto loads data/projects.yml into meta.projects.
    -- The page's project-id selects a record, for example projects["MS"].
    local project_id = text(meta["project-id"])
    local projects = assert(meta.projects, "Missing projects metadata")
    local project = assert(
      projects[project_id],
      "Unknown or missing project-id: " .. project_id
    )

    -- A project can have no highlights. In that case, skip the whole list.
    local highlights = project["project-highlights"]
    if not highlights or #highlights == 0 then
      return pandoc.Null()
    end

    local html = {
      '<ul class="d-flex flex-nowrap list-unstyled my-4" aria-label="Project highlights">'
    }

    -- Add one tile per highlight, in the order defined in projects.yml.
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

    -- Join the fragments and insert the HTML where the shortcode appears.
    html[#html + 1] = "</ul>"
    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}