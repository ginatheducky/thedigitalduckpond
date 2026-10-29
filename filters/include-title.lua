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

    local partial_path = quarto.utils.resolve_path(
        "../partials/printprojects/test.html"
    )

    local file = assert(io.open(partial_path, "r"))
    local template = file:read("*a")
    file:close()

    local compiled = pandoc.template.compile(template)
    local rendered = pandoc.template.apply(compiled, {
        title = title
    })

    quarto.doc.include_text("in-header", tostring(rendered))

    return meta
end