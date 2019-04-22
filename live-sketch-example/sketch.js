window.sketch = createProcessingSketch('*', function (self, p) {
  var record = null

  //
  // p5.js drawing code, default functions
  //
  p.setup = function () {
    p.createCanvas(self.width, self.height);
    p.noStroke();
  }

  p.draw = function () {
    p.background(0)

    if (record) {
      p.fill(255)
      p.text(JSON.stringify(record, null, '  '), 10, 20)
    }
  }

  p.onData = function (data) {
    record = data
  }
})
