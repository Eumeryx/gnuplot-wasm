# gnuplot-wasm

This is Gnuplot compiled to WebAssembly using Emscripten and supports SVG terminals only.

See [demo](https://eumeryx.github.io/gnuplot-wasm/).

## How to use

```html
<script src="https://cdn.jsdelivr.net/gh/Eumeryx/gnuplot-wasm/gnuplot.js"></script>
<script>
  createGnuplot()
    .then((gnuplot) => {
      try {
        gnuplot('plot x**2;', {x: 600, y: 480})
      } catch (err) {
        console.error(err)
      }
    })
    .catch((err) => console.error(err));
</script>
```

Or see [demo](./template/demo.html).

## How to build

You need [Emscripten SDK](https://emscripten.org/).

```bash
./build.sh install #install to `./dist` dir.
```
