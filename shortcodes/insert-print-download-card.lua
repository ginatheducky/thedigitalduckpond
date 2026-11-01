-- function for HTML escaping
local function escape_html(value)
    return value
        :gsub("&", "&amp;")
        :gsub('"', "&quot;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
end

-- validate the url
local function safe_url(value)
    if not value then
        return nil
    end

    local url = pandoc.utils.stringify(value)

    if url:match("^https://[%w]") then
        return escape_html(url)
    end

    return nil
end

-- function that generates a download button for any platform
local function make_button(url, label)
    local html = string.format([[
        <a href="%s" class="btn btn-warning btn-lg fw-bold w-100 mb-3" target="_blank" rel="noopener noreferrer">
            %s ↗
        </a>
    ]], url, label)

    return html
end


-- define the shortcode
return {
    ["insert-print-download-card"] = function(args, kwargs, meta)

        -- 1. read and validate metadata
        local platforms = {
            { name = "Printables", url = safe_url(meta.printables) },
            { name = "Makerworld", url = safe_url(meta.makerworld) }
        }

        -- check if there are any links available and don't generate a card if there are no links
        local has_links = false
        for _, platform in ipairs(platforms) do
            if platform.url then
                has_links = true
                break
            end
        end

        -- hide card if no buttons exist
        if not has_links then
            return pandoc.Null()
        end
    
        -- start building the card
        local html = [[
            <div class="card print-download-card shadow-sm my-4">
                <div class="card-header print-download-header d-flex justify-content-between align-items-center">
                    <span>&gt; print_your_own_</span>
                    <i class="bi bi-download fs-2" aria-hidden="true"></i>
                </div>
                <div class="card-body">
                    <h3 class="card-title">Like this project?</h3>
                    <p>Grab the files and start printing.</p>
        ]]
        
        -- add a perintables button if a url exists
        for _, platform in ipairs(platforms) do
            if platform.url then
                html = html .. make_button(platform.url, "Get files on " .. platform.name)
            end
        end

        -- close the card
        html = html .. [[
                </div>
            </div>
        ]]

        return pandoc.RawBlock("html", html)

    end
}