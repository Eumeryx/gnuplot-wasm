const { readFileSync } = require('fs');
const { exit } = require('process');
const createGnuplot = require('../dist/gnuplot.js');

let exitCode = 0;
console.info('0. Test gnuplot load:');

createGnuplot((importObject, callback) => {
  WebAssembly.instantiate(readFileSync(__dirname + '/../dist/gnuplot.wasm'), importObject)
    .then(({ instance }) => callback(instance))
    .catch(() => callback(false));

  return {};
}).then((gnuplot) => {
  console.info('...OK\n');

  console.info('1. Test gnuplot render:');
  const svg = gnuplot('plot x;', { x: 400, y: 700 });

  if (
    svg.includes('<?xml version="1.0" encoding="utf-8"  standalone="no"?>')
    && svg.includes('</svg>')
  ) {
    console.info('...OK\n');
  } else {
    console.error('...Failed\n');
    exitCode++;
  }

  console.info('2. Test invalid expression:');
  try {
    gnuplot('plot x*', { x: 400, y: 700 });
  } catch (err) {
    if (err.message === '\nplot x*\n       ^\n"input" line 1: invalid expression \n\n') {
      console.info('...OK\n');
    } else {
      console.error('...Failed\n');
      exitCode++;
    }
  }
}).catch(() => {
  console.error('...Failed\n');
  exitCode++;
}).finally(() => exit(exitCode));
