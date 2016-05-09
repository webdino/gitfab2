$(document).on "click", ".fork-btn", (event) ->
  event.preventDefault()
  form = $(this).find "form"
  form.submit()

$(document).on "click", "#print-btn", (event) ->
  event.preventDefault()
  window.print()

$ ->
  $("#collaborator_name").select2 {
    width: "40%",
    placeholder: "Choose a collaborator",
    allowClear: true,
    ajax: {
      url: "/owners.json",
      dataType: "json",
      cache: false,
      delay: 250,
      processResults: (data, params) ->
        collaboratorsList = []
        ownerName = $("#owner > span:nth-child(2)").text()
        collaboratorsList.push ownerName
        $(".collaboration > span.name").each (index, element) ->
          collaboratorsList.push $(element).text()
        return {
          results: $.map(data, (collaborator, i) ->
            collaboratorName = collaborator.name
            collaboratorSlug = collaborator.slug
            if $.inArray(collaboratorName, collaboratorsList) == -1 && collaboratorName.indexOf(params.term) != -1
              return {id: collaboratorSlug, text: collaboratorName}
          )
        }
    }
  }

  $(".show-project-relation-tree-link").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

  $(".change-owner-btn").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

  $("#add-collaborator-btn").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

  $(".colorbox-link").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

$(document).on "click", ".select2-container", (event) ->
  $(".dropdown-wrapper").first().append $(".select2-dropdown").first()

$(document).on "click", ".select2-dropdown", (event) ->
  event.stopPropagation()

$(document).on "click", ".show-project-relation-tree-link", (event) ->
  $("#project-relation-tree svg").remove()
  width = $(window).width() - 100
  height = $(window).height() - 160
  url = $("#project-relation-tree").data("url")
  svg = d3.select("#project-relation-tree").append("svg")
  .attr("width", width)
  .attr("height", height)

  tree = d3.layout.tree()
  .size([height - 200, width - 200])
  .children(children)

  d3.json url, (data) ->
    common_gray = "#999999"
    common_basic_color = "#52C3F1"

    nodes = tree.nodes data
    links = tree.links nodes
    node = svg.selectAll(".node")
    .data(nodes)
    .enter()
    .append("g")
    .attr("class", "node")
    .attr "transform", (d) ->
      return "translate(" + (d.y + 10) + "," + (d.x + 100) + ")"

    node.append("circle")
    .attr("r", 8)
    .attr("fill", ((d) -> return if d.this then common_basic_color else common_gray))
    .on("mouseover", (d) ->
      d3.select(this)
      .attr("opacity", "0.6")
      .style("cursor", "pointer")
      d3.select(this.parentNode).select("text")
      .attr("opacity", "0.6")
      .attr("font-size", "14px")
    )
    .on("mouseout", (d) ->
      d3.select(this).attr "opacity", "1.0"
      d3.select(this.parentNode).select("text")
      .attr("opacity", "1.0")
      .attr("font-size", "12px")
    )
    .on("click", showLink)

    node.append("text")
    .text((d) -> return d.name)
    .attr("x", 10)
    .attr("y", -10)
    .attr("font-size", "12px")
    .on("mouseover", (d) ->
      d3.select(this)
      .attr("font-size", "14px")
      .attr("opacity", "0.6")
      .style("cursor", "pointer")
      d3.select(this.parentNode).select("circle").attr "opacity", "0.6"
    )
    .on("mouseout", (d) ->
      d3.select(this)
      .attr("font-size", "12px")
      .attr("opacity", "1.0")
      d3.select(this.parentNode).select("circle").attr "opacity", "1.0"
    )
    .on("click", showLink)

    diagonal = d3.svg.diagonal()
    .projection ((d) -> return([d.y + 10, d.x + 100]))

    svg.selectAll(".link")
    .data(links)
    .enter()
    .append("path")
    .attr("class", "link")
    .attr("fill", "none")
    .attr("stroke", common_gray)
    .attr("d", diagonal)

window.showLink = (d) ->
  if d.url == "http://fabble.cc" || d.url == "https://fabble.cc"
    alert "You cannot see this project."
  else
    window.open d.url, "_blank"

window.children = (d) ->
  return d["children"]

window.clearSelect2Value = () ->
  $("#s2id_user_name").select2 "val",""
  $("input#user_name").val ""
