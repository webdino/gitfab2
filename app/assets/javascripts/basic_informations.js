$(document).on("click", ".fork-btn", function(event) {
  event.preventDefault();
  $(".modal").modal("hide");
  $("#modal-loading").modal("show");
  $(this).find("form").submit();
});

$(document).on("click", "#print-btn", function(event) {
  event.preventDefault();
  window.print();
});

$(function() {
  $("#collaborator_name").select2({
    width: "40%",
    placeholder: "Choose a collaborator",
    allowClear: true,
    ajax: {
      url: "/owners.json",
      dataType: "json",
      cache: false,
      delay: 250,
      processResults(data, params) {
        const collaboratorsList = [];
        const ownerName = $("#owner > span:nth-child(2)").text();
        collaboratorsList.push(ownerName);
        $(".collaboration > span.name").each((index, element) => collaboratorsList.push($(element).text()));
        return {
          results: $.map(data, function(collaborator, i) {
            const collaboratorName = collaborator.name;
            const collaboratorSlug = collaborator.slug;
            if (($.inArray(collaboratorName, collaboratorsList) === -1) && (collaboratorName.indexOf(params.term) !== -1)) {
              return {id: collaboratorSlug, text: collaboratorName};
            }
          })
        };
      }
    }
  });
});

$(document).on("click", ".select2-container", event => $(".dropdown-wrapper").first().append($(".select2-dropdown").first()));

$(document).on("click", ".select2-dropdown", event => event.stopPropagation());

$(document).on("click", ".show-project-relation-tree-link", function() {
  $("#project-relation-tree svg").remove();
  const width = $(window).width() - 100;
  const height = $(window).height() - 160;
  const url = $("#project-relation-tree").data("url");
  const svg = d3.select("#project-relation-tree").append("svg")
  .attr("width", width)
  .attr("height", height);

  const tree = d3.layout.tree()
  .size([height - 200, width - 200])
  .children(children);

  d3.json(url, function(data) {
    const common_gray = "#999999";
    const common_basic_color = "#52C3F1";

    const nodes = tree.nodes(data);
    const links = tree.links(nodes);
    const node = svg.selectAll(".node")
    .data(nodes)
    .enter()
    .append("g")
    .attr("class", "node")
    .attr("transform", d => `translate(${d.y + 10},${d.x + 100})`);

    node.append("circle")
    .attr("r", 8)
    .attr("fill", (function(d) { if (d.this) { return common_basic_color; } else { return common_gray; } }))
    .on("mouseover", function(d) {
      d3.select(this)
      .attr("opacity", "0.6")
      .style("cursor", "pointer");
      d3.select(this.parentNode).select("text")
      .attr("opacity", "0.6")
      .attr("font-size", "14px");
    })
    .on("mouseout", function(d) {
      d3.select(this).attr("opacity", "1.0");
      d3.select(this.parentNode).select("text")
      .attr("opacity", "1.0")
      .attr("font-size", "12px");
    })
    .on("click", showLink);

    node.append("text")
    .text(d => d.name)
    .attr("x", 10)
    .attr("y", -10)
    .attr("font-size", "12px")
    .on("mouseover", function(d) {
      d3.select(this)
      .attr("font-size", "14px")
      .attr("opacity", "0.6")
      .style("cursor", "pointer");
      d3.select(this.parentNode).select("circle").attr("opacity", "0.6");
    })
    .on("mouseout", function(d) {
      d3.select(this)
      .attr("font-size", "12px")
      .attr("opacity", "1.0");
      d3.select(this.parentNode).select("circle").attr("opacity", "1.0");
    })
    .on("click", showLink);

    const diagonal = d3.svg.diagonal()
    .projection((d => [d.y + 10, d.x + 100]));

    svg.selectAll(".link")
    .data(links)
    .enter()
    .append("path")
    .attr("class", "link")
    .attr("fill", "none")
    .attr("stroke", common_gray)
    .attr("d", diagonal);
  });
});

window.showLink = function(d) {
  if ((d.url === "http://fabble.cc") || (d.url === "https://fabble.cc")) {
    alert("You cannot see this project.");
  } else {
    window.open(d.url, "_blank");
  }
};

window.children = d => d["children"];
