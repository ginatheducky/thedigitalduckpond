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


return {
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
      ]], make_icon(item["icon"]), escape_html(item["text"]))
    end

    html[#html + 1] = "</ul>"

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}