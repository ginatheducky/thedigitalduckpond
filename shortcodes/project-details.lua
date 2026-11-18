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
  ["project-details"] = function(args, kwargs, meta)
    local details = meta["project-details"] or {}
    local html = { '<dl class="d-flex flex-column gap-3 my-3">' }

    for _, field in ipairs(detail_fields) do
        local value = details[field["key"]]

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
        make_icon(field["icon"]),
        escape_html(field["label"]),
        escape_html(field["label"]),
        escape_html(value)
        )
    end

    html[#html + 1] = "</dl>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end
}