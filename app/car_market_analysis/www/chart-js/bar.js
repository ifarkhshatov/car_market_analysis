

function barChart(canvasId, dataChartFromShiny, title, horizontal, stacked, labels, x_axis_label, y_axis_label, show_grid, show_legend) {

  var ctx = document.getElementById(canvasId);
  var gradient = ctx.getContext("2d").createLinearGradient(0, 0, 0, 400);
  gradient.addColorStop(1, 'rgba(85, 60, 154,1)');
  gradient.addColorStop(0, 'rgba(238, 75, 43,1)');
  // get active bar id in onClick
  var activeBar = [];
  var TITLE = title

  // `false` for vertical column chart, `true` for horizontal bar chart
  var HORIZONTAL = horizontal

  // `false` for individual bars, `true` for stacked bars
  var STACKED = stacked

  // Which column defines 'bucket' names?
  var LABELS = labels;

  var SERIES = dataChartFromShiny

  // x-axis label and label in tooltip
  var X_AXIS = x_axis_label;

  // y-axis label, label in tooltip
  var Y_AXIS = y_axis_label;

  // `true` to show the grid, `false` to hide
  var SHOW_GRID = show_grid;

  // `true` to show the legend, `false` to hide
  var SHOW_LEGEND = show_legend;

  var datasets = [{
    data: dataChartFromShiny.map(x => x.x),
    fill: true,
    label: TITLE,
    backgroundColor: gradient,
  }];

  var barChartData = {
    labels: [...new Set(dataChartFromShiny.map(x => x.labels))],
    datasets: datasets
  }

  new Chart(ctx, {
    type: HORIZONTAL ? 'horizontalBar' : 'bar',
    data: barChartData,

    options: {
      title: {
        display: false,//true,
        text: TITLE,
        fontSize: 14,
      },
      legend: {
        display: SHOW_LEGEND,
      },
      scales: {
        xAxes: [{
          stacked: STACKED,
          scaleLabel: {
            display: X_AXIS !== '',
            labelString: X_AXIS
          },
          gridLines: {
            display: false//SHOW_GRID,
          },
          ticks: {
            beginAtZero: true,
            callback: function (value, index, values) {
              if (!isNaN(value) || !value === undefined) {
                // need to add this to function value input
                // return value.toLocaleString();
                return value
              } else {
                return value
              }
            }
          }
        }],
        yAxes: [{
          stacked: STACKED,
          beginAtZero: true,
          scaleLabel: {
            display: Y_AXIS !== '',
            labelString: Y_AXIS
          },
          gridLines: {
            display: SHOW_GRID,
          },
          ticks: {
            beginAtZero: true,
            callback: function (value, index, values) {
              return value.toLocaleString()
            }
          }
        }]
      },
      tooltips: {
        displayColors: false,
        callbacks: {
          label: function (tooltipItem, all) {
            // return parsed data on hover bar, point
            return tooltipItem.yLabel.toLocaleString();
            //all.datasets[tooltipItem.datasetIndex].label
            // + ': ' + 
          }
        }
      },
      // on click function
      // on click on area of char do nothing since i[0] <- is Undefined
      // otherwise return back chart id, and x + y value to Shiny in order to redraw/refilter data
      onClick: function (c, i) {
        e = i[0];
        // send back to SHINY
        if (e !== undefined) {
          var id = this['canvas'].id;
          var x_value = this.data.labels[e._index];
          var y_value = this.data.datasets[0].data[e._index];
          // only for last chart
          //  if (id == 'chart-stats-0' && !isNaN(x_value)) {
          // change color of clicked
          // if already click then gradient all 
          // if current id in activeBar, then unclick 
          if (activeBar.find(x => x == x_value)) {
            this.data.datasets[0].backgroundColor = gradient;
            activeBar = [];
            // if current bar is not highlighted then highlighted also
          } else if (this.data.datasets[0].backgroundColor[e._index] == '#cccccc') {
            this.data.datasets[0].backgroundColor[e._index] = gradient;
            activeBar.push(x_value);
          } else {
            this.data.datasets[0].backgroundColor = Array(this.data.labels.length).fill('#cccccc');
            this.data.datasets[0].backgroundColor[e._index] = gradient;
            activeBar.push(x_value);
          }
          this.update()

          // on click send back to shiny server data into input$returnFromUI in server.R
          Shiny.setInputValue('returnFromUI', {
            id,
            x_value,
            y_value,
            activeBar
          })

          console.log(activeBar)
          //  }
        }
      }
    }
  });
}


//   var options = {
//     responsive: true,
//     datasetStrokeWidth : 3,
//     pointDotStrokeWidth : 4,
//     tooltipFillColor: "rgba(0,0,0,0.8)",
//     tooltipFontStyle: "bold",
//     tooltipTemplate: "<%if (label){%><%=label + ' hod' %>: <%}%><%= value + '°C' %>",
//     scaleLabel : "<%= Number(value).toFixed(0).replace('.', ',') + '°C'%>"
// };