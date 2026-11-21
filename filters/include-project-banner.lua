-- Convert Pandoc's inline content to HTML for the banner template.
-- This preserves Markdown formatting such as *emphasis*.
local function as_html(inlines)
    if inlines then
        local html = pandoc.write(
            pandoc.Pandoc({ pandoc.Plain(inlines) }),
            "html"
        )

        -- Pandoc adds a trailing newline. Remove trailing whitespace.
        return (html:gsub("%s+$", ""))
    end
end

-- Pandoc calls Meta with the document's metadata.
-- Quarto has already loaded data/projects.yml through _quarto.yml, so the shared project records are available in meta.projects.
function Meta(meta)
    -- Read the page's top-level project-id and turn it into a Lua string so it can be used as a key, for example projects["MS"].
    local project_id = pandoc.utils.stringify(meta["project-id"] or "")
    local projects = assert(meta.projects, "Missing projects metadata")
    local project = assert(
        projects[project_id],
        "Unknown or missing project-id: " .. project_id
    )

    -- Categories belong to the individual page. Convert each category to HTML and keep the same order as in the page's front matter.
    local categories
    if meta.categories then
        categories = {}
        for _, category in ipairs(meta.categories) do
            categories[#categories + 1] = as_html(category)
        end
    end

    -- Find the HTML template relative to this filter and read it into a string. 
    -- The empty title-block.html is a separate partial that suppresses Quarto's default title block.
    local partial_path = quarto.utils.resolve_path(
        "../partials/projects/project-banner.html"
    )
    local file = assert(io.open(partial_path, "r"))
    local template = file:read("*a")
    file:close()

    -- Compile the template, then supply the values for its $...$ fields.
    local compiled = pandoc.template.compile(template)
    local rendered = pandoc.template.apply(compiled, {
        title = as_html(project.title),
        subtitle = as_html(project.subtitle),
        categories = categories
    })

    -- Add the rendered banner through Quarto's header include.
    quarto.doc.include_text("in-header", tostring(rendered))

    -- Give Pandoc back the document metadata. The banner values above were passed separately to the template.
    return meta
end