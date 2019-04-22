// HANDY LINKS:
//
// p5.js ->       https://p5js.org/reference/
// javascript ->  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference
// micavibe ->    http://micavibe.com
// adafruit IO -> https://io.adafruit.com/mica_ia/public
//

window.sketch = createProcessingSketch('*', function (self, p) {

  /*
   *
   * Make changes inside this function
   *
   * All processing functions should be prefixed with `p.`
   *
   * If you want to receive data from a single station, use 'sound', 'sound2',
   * 'split-motion', or 'mood' in place of '*' above.
   *
   */

  var record = null
  var moods = []

  //
  // p5.js drawing code. The default functions every sketch should define are p.setup and p.draw.
  //
  p.setup = function () {
    // the `self` record has the initial sketch dimensions. To change the size
    // of the canvas on the page, see index.html and the <div> element with id="container"
    p.createCanvas(self.width, self.height);

    p.noStroke();

    // See the `onData` function below for an example of handling live records
    // OR use the `getData` function to make a request when the sketch starts.
    p.getData('mood', 10).then(function (records) {
      moods = []

      records.
        map(function (datum) {
          // splitting records
          return datum.value.split(' ')
        }).
        map(function (values) {
          // converting values to numbers
          return values.map(function (value) { return parseInt(value) })
        }).
        forEach(function (values) {
          // finally building a single list of values
          moods = moods.concat(values)
        })

      console.log("GOT MOOD RECORDS:", moods)
    })
  }

  p.draw = function () {
    p.background(0)

    if (record) {
      p.fill(255)
      p.text(JSON.stringify(record, null, '  '), 10, 20)
    }
  }

  // This function is called every time new data is received.
  p.onData = function (data) {
    // data.value for all stations is:
    // * a string
    // * containing one or more numbers
    // * separated by spaces
    //
    // what the value represents depends on the station
    //
    // we can get at the actual number values like this:
    var values = data.value.
      // splitting values
      split(' ').
      // converting to numbers
      map(function (value) { return parseInt(value) })

    // now we have a list of numbers for the `data.key` feed
    record = {
      key: data.key,
      values: values
    }
  }
})

