
-- Custom Bootstrap image carousel for Quarto
-- Converts Divs with the class "duck-carousel" into
-- Bootstrap 5 carousel HTML.

local carousel_count = 0

function Div(el)

  -- Only process our carousel blocks
  if not el.classes:includes("duck-carousel") then
    return nil
  end

  -- Only generate HTML for HTML output
  if not quarto.doc.is_format("html") then
    return nil
  end

  -- Create a unique ID for each carousel
  carousel_count = carousel_count + 1

  local id = el.identifier

  if id == "" then
    id = "duck-carousel-" .. carousel_count
  end

  -- Collect images from the Markdown block
  local images = {}

  for _, block in ipairs(el.content) do
    if block.t == "Para" or block.t == "Plain" then
      for _, inline in ipairs(block.content) do
        if inline.t == "Image" then
          table.insert(images, inline)
        end
      end
    end
  end

  if #images == 0 then
    return nil
  end

  -- Build Bootstrap HTML
  local html = {}

  table.insert(html,
    '<div id="' .. id .. '" class="carousel slide duck-carousel">'
  )

  table.insert(html, '<div class="carousel-inner">')

  for i, img in ipairs(images) do

    local active = ""
    if i == 1 then
      active = " active"
    end

    local src = img.src

    local alt = pandoc.utils.stringify(img.caption)

    table.insert(html,
      '<div class="carousel-item' .. active .. '">'
    )

    table.insert(html,
      '<img src="' .. src .. '" class="d-block" alt="' .. alt .. '">'
    )

    table.insert(html, '</div>')

  end

  table.insert(html, '</div>')

  -- Previous button
  table.insert(html, [[
    <button class="carousel-control-prev"
            type="button"
            data-bs-target="#]] .. id .. [["
            data-bs-slide="prev">
      <span class="carousel-control-prev-icon"
            aria-hidden="true"></span>
      <span class="visually-hidden">Previous</span>
    </button>
  ]])

  -- Next button
  table.insert(html, [[
    <button class="carousel-control-next"
            type="button"
            data-bs-target="#]] .. id .. [["
            data-bs-slide="next">
      <span class="carousel-control-next-icon"
            aria-hidden="true"></span>
      <span class="visually-hidden">Next</span>
    </button>
  ]])

  table.insert(html, '</div>')

  return pandoc.RawBlock("html", table.concat(html, "\n"))

end
