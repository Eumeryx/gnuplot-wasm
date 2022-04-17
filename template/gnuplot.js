(() => {
  var currentScript = typeof document != 'undefined'
    ? document.currentScript
    : undefined;

  var createGnuplot = (instantiateWasm) =>
    new Promise((resolve, reject) => {
      var errInfo;

      var Module = {
        'printErr': (err) => errInfo += `${err}\n`,
        'onAbort': reject,
        'onRuntimeInitialized': () => resolve((input, size) => {
          errInfo = '';
          size = size ? `size ${size.x},${size.y}` : '';

          FS.writeFile('input', input ? input : '');
          callMain(['-e', `set o "output";set t svg ${size} dynamic enhanced;`, 'input']);
          var output = FS.readFile('output', { encoding: 'utf8' });

          FS.unlink('input');
          FS.unlink('output');

          if (errInfo) throw new Error(errInfo);

          return output;
        }),
        'instantiateWasm': typeof instantiateWasm === 'function' ? instantiateWasm : undefined
      };

      //{{output.js}}

    });

  if (typeof exports === 'object' && typeof module === 'object') {
    module.exports = createGnuplot;
  } else if (typeof define === 'function' && define['amd']) {
    define([], function () { return createGnuplot; });
  } else if (typeof exports === 'object') {
    exports["createGnuplot"] = createGnuplot;
  } else {
    this["createGnuplot"] = createGnuplot;
  };
})();
