(() => {
  var currentScript = typeof document != 'undefined'
    ? document.currentScript
    : undefined;

  var createGnuplot = (instantiateWasm) =>
    new Promise((resolve, reject) => {
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
