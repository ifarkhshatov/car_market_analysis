
  
  function barChart(canvasId, dataChartFromShiny, title, horizontal, stacked, labels, x_axis_label, y_axis_label, show_grid, show_legend) {

    var TITLE = title
  
    // `false` for vertical column chart, `true` for horizontal bar chart
    var HORIZONTAL = horizontal
  
      // `false` for individual bars, `true` for stacked bars
    var STACKED = stacked  
    
    // Which column defines 'bucket' names?
    var LABELS = labels;  
  
    // For each column representing a data series, define its name and color
    // var SERIES = [  
    //   {
    //     column: 'nonlearner',
    //     name: 'Non-Learners',
    //     color: 'grey'
    //   },
    //   {
    //     column: 'learner',
    //     name: 'Learners',
    //     color: 'blue'
    //   }
    // ];
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
        backgroundColor: '#3c8dbc',
        }];

      var barChartData = {
        labels:  [...new Set(dataChartFromShiny.map(x => x.labels))],
        datasets: datasets
      }
  
      var ctx = document.getElementById(canvasId);
  
      new Chart(ctx, {
        type: HORIZONTAL ? 'horizontalBar' : 'bar',
        data: barChartData,
        
        options: {
          title: {
            display: true,
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
                display: SHOW_GRID,
              },
              // ticks: {
              //   beginAtZero: true,
              //   callback: function(value, index, values) {
              //     return value.toLocaleString();
              //   }
              // }
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
                callback: function(value, index, values) {
                  return value.toLocaleString()
                }
              }
            }]
          },
          tooltips: {
            displayColors: false,
            callbacks: {
              label: function(tooltipItem, all) {
                return all.datasets[tooltipItem.datasetIndex].label
                  + ': ' + tooltipItem.yLabel.toLocaleString();
              }
            }
          }
        }
      });
  }