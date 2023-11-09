var errInfo;

Module['printErr'] = (err) => errInfo += `${err}\n`;

Module['onAbort'] = reject;

Module['onRuntimeInitialized'] = () => resolve((input, size) => {
    errInfo = '';
    size = size ? `size ${size.x},${size.y}` : '';

    FS.writeFile('input', input ? input : '');
    callMain(['-e', `set o "output";set t svg ${size} dynamic enhanced;`, 'input']);
    var output = FS.readFile('output', { encoding: 'utf8' });

    FS.unlink('input');
    FS.unlink('output');

    if (errInfo) throw new Error(errInfo);

    return output;
});

Module['instantiateWasm'] = typeof instantiateWasm === 'function' ? instantiateWasm : undefined;