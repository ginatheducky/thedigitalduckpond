-- Convert a Pandoc metadata value to plain text.
local function text(value)
    return value == nil and "" or pandoc.utils.stringify(value)
end

-- Escape characters before inserting a URL into an HTML attribute.
local function escape_html(value)
    return (value
        :gsub("&", "&amp;")
        :gsub('"', "&quot;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;"))
end

-- Accept only links starting with https:// and an alphanumeric character.
-- Missing or empty links return nil, so their buttons are skipped.
local function safe_url(value)
    local url = text(value)
    if url:match("^https://[%w]") then
        return escape_html(url)
    end
    return nil
end

-- Build a button for a platform with a usable link.
local function make_button(url, platform_name)
    return string.format([[
        <a href="%s" class="btn btn-warning btn-lg fw-bold w-100 mb-3" target="_blank" rel="noopener noreferrer">
            Get files on %s
        </a>
    ]], url, platform_name)
end

return {
    ["insert-print-download-card"] = function(args, kwargs, meta)
        -- The page's project-id selects a shared record in data/projects.yml.
        -- For example, project-id: MS selects projects["MS"].
        local project_id = text(meta["project-id"])
        local projects = assert(meta.projects, "Missing projects metadata")
        local project = assert(
            projects[project_id],
            "Unknown or missing project-id: " .. project_id
        )

        -- A project can exist before its print files are available.
        local links = project.links or {}
        local printables_url = safe_url(links.printables)
        local makerworld_url = safe_url(links.makerworld)

        -- Skip the whole card when there are no download buttons to show.
        if not printables_url and not makerworld_url then
            return pandoc.Null()
        end

        local html = {
            [[
            <div class="card print-download-card shadow-sm my-4">
                <div class="card-header print-download-header d-flex justify-content-between align-items-center">
                    <span>&gt; print_your_own_</span>
                    <i class="bi bi-download fs-2" aria-hidden="true"></i>
                </div>
                <div class="card-body">
                    <h3 class="card-title">Like this project?</h3>
                    <p>Grab the files and start printing.</p>
            ]]
        }

        if printables_url then
            html[#html + 1] = make_button(printables_url, "Printables")
        end

        if makerworld_url then
            html[#html + 1] = make_button(makerworld_url, "MakerWorld")
        end

        html[#html + 1] = [[
                </div>
            </div>
        ]]

        -- Insert the completed card at the shortcode's location in the page.
        return pandoc.RawBlock("html", table.concat(html, "\n"))
    end
}