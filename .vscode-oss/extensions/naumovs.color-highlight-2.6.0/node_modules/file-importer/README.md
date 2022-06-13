# file-importer

An `@import` statement processor for assembling Sass and other source file trees into a flattened source. This is useful for assembling a raw Sass codebase into an aggregate source, or using the Sass `@import` workflow as an aggregator for other filetypes.

This is a lightweight standalone library; it does NOT dependend on an actual Sass engine. All files are read, parsed for imports, and assembled entirely as plain text. File access and compilation is performed directly through Node, and `@import` statements are parsed from texts using regular expressions.

**So... I can assemble my Sass source tree into a flat file?**

Yes. However – be mindful that imports are resolved through plain text that is not contextually aware, therefore `@import` statements within comments will still be discovered and parsed. For lexically-aware parsing of Sass source trees, see the [sass-ast](https://github.com/gmac/sass-ast) project.


## Install

```
npm install file-importer --save-dev
```

## Usage

```javascript
var path = require('path');
var fileImporter = require('file-importer');

fileImporter.parse({
    file: 'lib/index',
    cwd: path.resolve(__dirname),
    includePaths: ['./base/']
  },
  function(err, data) {
    if (err) throw err;
    console.log(data);
  });
```

### fileImporter.parse( options, callback )

#### Required options, one or both:

* **`file`**: String path to the file to load and parse. This may be an absolute path, or else a relative path from `process.cwd()` (or the provided `cwd` option). Uses `./` by default.

* **`data`**: String data to parse. When provided, file read is skipped and the provided string is parsed as file contents. You may still provide a `file` option as path context for mapping imports.

#### Optional options:

* **`cwd`**: Path of the directory to resolve `file` reference and `includePaths` from. Uses `process.cwd()` by default.

* **`includePaths`**: Array of base paths to search while perform file lookups. These should be absolute directory paths, or else relative to `process.cwd()` (or the provided `cwd` option).

* **`extensions`**: Array of file extensions to search while performing lookups. Set as `['.scss']` by default (for standard Sass import behavior). You could set this to, say, `['.txt']` to import a tree of plain text files.

## Import Rules

Sass-style imports are fairly blunt instruments. There's not a lot of magic here:

**To parse `lib/sfoo`:**

1. Look for `<cwd>/lib/sfoo`. If it's a directory, import all contents.
2. Look for `<cwd>/lib/sfoo.scss`. FileImporter does this with all provided extensions.
3. Look for `<cwd>/lib/_sfoo.scss`. FileImporter does this with all provided extensions.
4. Perform steps 1-3 swapping `<cwd>` for each of `includePaths`.

## Test

To run tests:

```
npm test
```
