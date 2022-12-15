
// Data from side bar 
var filterData;
Shiny.addCustomMessageHandler("filterData", function (data) {
    filterData = data;
})

// Getting info from server
Shiny.addCustomMessageHandler("dataChartJS_scatter", function (data) {
    iss = data
        drawChart('.chart', data[3], 'bar', 'Market', 0, false, false, 'price', 'Car Brand', 'Quantity on market', true, false);
        drawChart('.chart', data[2], 'bar', 'AVG Price to Odometer', 1, false, false, 'price', 'Odometer', 'Price', true, false);
        drawChart('.chart', data[4], 'bar', 'AVG Price to Year', 2, false, false, 'price', 'Year', 'Price', true, false);


})

// find div clean and draw figure there
function drawChart(divName, dataChartFromShiny, chartType, chartLabel, ids,horizontal, stacked, labels, x_axis_label, y_axis_label, show_grid, show_legend) {
    var canvasId = 'chart-stats-' + ids
    $(divName).eq(ids).empty();
    $(divName).eq(ids).append(
        '<canvas id="' + canvasId + '"></canvas>'
    );
    barChart(canvasId, dataChartFromShiny, chartLabel, horizontal, stacked, labels, x_axis_label,y_axis_label, show_grid, show_legend);

}