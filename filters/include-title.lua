function Meta(meta)
    local title = nil
    if meta.title then
        title = pandoc.write(
            pandoc.Pandoc({
                pandoc.Plain(meta.title)
            }),
            "html"
        )
    end

    local subtitle = nil
    if meta.subtitle then
        subtitle = pandoc.write(
            pandoc.Pandoc({
                pandoc.Plain(meta.subtitle)
            }),
            "html"
        )
    end

    local partial_path = quarto.utils.resolve_path(
        "../partials/printprojects/print-banner.html"
    )

    local file = assert(io.open(partial_path, "r"))
    local template = file:read("*a")
    file:close()

    local compiled = pandoc.template.compile(template)
    local categories = nil
    if meta.categories then
        categories = {}
        for _, category in ipairs(meta.categories) do
            local category_html = pandoc.write(
                pandoc.Pandoc({ pandoc.Plain(category) }),
                "html"
            ):gsub("%s+$", "")
            table.insert(categories, category_html)
        end
    end

    local rendered = pandoc.template.apply(compiled, {
        title = title,
        subtitle = subtitle,
        categories = categories
    })

    quarto.doc.include_text("in-header", tostring(rendered))

    return meta
end
