var assert = require('assert');
var Mocha = require('mocha');
var mocha = new Mocha();

// Add custom assertions:
assert.contain = function(a, b) {
  if (a.indexOf(b) == -1) {
    assert.fail(a, b, 'expected to contain');
  }
};

assert.doesNotContain = function(a, b) {
  if (a.indexOf(b) != -1) {
    assert.fail(a, b, 'expected not to contain');
  }
};

assert.match = function(a, b) {
  if (!b.test(a)) {
    assert.fail(a, b, 'expected not match');
  }
};

mocha.reporter('dot');
mocha.addFile('test/resolution');
mocha.addFile('test/imports');
mocha.addFile('test/paths');
mocha.addFile('test/scenarios');

mocha.run(function(failures) {
  process.on('exit', function() {
    process.exit(failures);
  });
});