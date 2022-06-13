var fs = require('fs');
var path = require('path');
var EventEmitter = require('events').EventEmitter;
var dir = require('node-dir');

// Extend object properties onto base:
function extend(base) {
  for (var i = 1; i < arguments.length; i++){
    var ext = arguments[i];
    for (var key in ext) if (ext.hasOwnProperty(key)) base[key] = ext[key];
  }
  return base;
}

/**
 * A virtual file object for managing loaded file.
 * @option { String } file: relative file reference.
 * @option { String } data: string data for the file contents.
 * @option { String } cwd: optional path to use as the file's CWD.
 * @option { Array } includePaths: optional array of other base search paths.
 * @option { Array } extensions: optional array of file extensions to resolve.
 * @option { Array } branch: previous imports within the file tree (tracks recursion).
 */
function File(opts) {
  EventEmitter.call(this);
  this.extensions = Array.isArray(opts.extensions) ? opts.extensions : ['.scss'];
  this.includePaths = Array.isArray(opts.includePaths) ? opts.includePaths : [];
  this.root = opts.root || this;
  this.branch = opts.branch || [];
  this.filepath = opts.filepath || null;
  this.cwd = opts.cwd || process.cwd();
  this.file = opts.file || './';
  this.data = (typeof opts.data === 'string') ? opts.data : null;
  this.lookups = [];
  this._parsed = false;

  // Map includePaths into absolute paths:
  this.includePaths = this.includePaths.map(function(include) {
    return path.isAbsolute(include) ? include : path.join(this.cwd, include);
  }.bind(this));

  // Set absolute paths as a hard lookup:
  if (path.isAbsolute(this.file)) {
    this.lookups.push(this.file);
    return this;
  }

  // Assemble complete list of base lookup paths:
  // (this is the file's given cwd, and included search paths)
  var basePaths = [this.cwd].concat(this.includePaths);
  var meta = path.parse(this.file);

  // Build lookup paths upon all base paths:
  for (var i=0; i < basePaths.length; i++) {
    var basePath = basePaths[i];

    for (var j=0; j < this.extensions.length; j++) {
      // Given filename + extension:
      // ex: "lib/file" => "/base/lib/file.scss"
      if (!meta.ext)
        this.lookups.push(path.join(basePath, meta.dir, meta.name + this.extensions[j]));

      // Prefixed filename + extension:
      // ex: "lib/file" => "/base/lib/_file.scss"
      if (meta.name[0] !== '_')
        this.lookups.push(path.join(basePath, meta.dir, '_'+ meta.name + this.extensions[j]));
    }

    // Given filename:
    // ex: "lib/file" => "/base/lib/file"
    this.lookups.push(path.join(basePath, this.file));
  }
}

File.prototype = extend({}, EventEmitter.prototype, {
  _extend: extend,
  
  // Specifies if the file had been read:
  // (fulfilled once the file has been given data)
  isLoaded: function() {
    return (typeof this.data === 'string');
  },

  // Specifies if the file has been parsed:
  // (fulfilled once the file has data and has completed parsing pass)
  isParsed: function() {
    return this.isLoaded() && this._parsed;
  },

  // Renders the file contents:
  // @param { Function } done the fn to invoke upon completion. Invoked with (err, file).
  render: function(done) {
    var self = this;

    function complete() {
      done(null, self);
    }

    // File needs data loaded:
    if (!this.isLoaded()) {
      self.load(function(err) {
        if (err) throw err;
        self.parse(complete);
      });
    }
    // File data needs to be parsed:
    else if (!this.isParsed()) {
      self.parse(complete);
    }
    // File is ready to go:
    else {
      complete();
    }

    return this;
  },

  /**
   * Resolves file data based upon the file's array of lookup paths.
   * Each lookup path is accessed until a file is found, or options are exhausted.
   * @param { Function } done the fn to invoke upon completion. Invoked with (err, file).
   */
  load: function(done) {
    var self = this;
    var index = arguments[1] || 0;
    var lookupFile = self.lookups[index];
    var loadedFiles = [];

    if (!lookupFile) {
      return done(new Error('Import "'+ self.file +'" could not be resolved.'));
    }

    fs.lstat(lookupFile, function(err, stats) {
      // Error:
      if (err) {
        if (err.code === 'ENOENT') return self.load(done, index+1);
        else return self.root.emit('error', err);
      }

      // Recursive file access:
      if (self.branch.indexOf(lookupFile) != -1) {
        return self.root.emit('error', new Error('Recursive import "'+ lookupFile +'" could not be resolved.'));
      } else {
        self.branch.push(lookupFile);
        self.filepath = lookupFile;
      }

      // Directory:
      if (stats.isDirectory()) {
        dir.readFiles(lookupFile, {
          recursive: false,
          match: new RegExp( self.extensions.map(function(ext) { return ext + '$'; }).join('|') ),
          exclude: /^\./
        },
        function(err, data, filename, next) {
          if (err) throw err;
          addFile(filename, data);
          next();
        },
        function(err, filenames) {
          if (err) throw err;
          renderFile();
        });
      }

      // File:
      else if (stats.isFile()) {
        fs.readFile(lookupFile, function(err, data) {
          if (err) throw err;
          addFile(lookupFile, data.toString('utf-8'));
          renderFile();
        });
      }
    });

    // Queues a new file within the array of loaded files:
    // Loaded files localize their own CWD for relative imports.
    function addFile(filepath, data) {
      var meta = path.parse(filepath);

      loadedFiles.push(self.fork({
        cwd: meta.dir,
        file: meta.base,
        filepath: filepath,
        data: data
      }));

      self.root.emit('file', filepath);
    }
    
    // Processes file contents:
    // Called upon completing load of all accessed files.
    // Files are now rendered individually, then handed off to seed the parent.
    function renderFile() {
      // Callback on completion of each render:
      // We'll look through all files to see if everything is ready to go.
      function next(err, file) {
        if (err) throw err;

        for (var i=0; i < loadedFiles.length; i++) {
          if (!loadedFiles[i].isParsed()) return;
        }

        self.compile(loadedFiles);
        done(null, self);
      }

      // Render all loaded files:
      for (var i=0; i < loadedFiles.length; i++) {
        loadedFiles[i].render(next);
      }
    }

    return this;
  },

  /**
   * Compiles the file with all loaded data.
   * Resolves situations where many files compile into a single parent.
   * @param { Array } files an array of File objects to seed file data from.
   */
  compile: function(files) {
    this.data = '';
    for (var i=0; i < files.length; i++) {
      this.data += files[i].data + '\n';
    }
    return this;
  },

  /**
   * Parses all @import statements within a file.
   * Each import creates a new file to load and render into the source.
   * @param { Function } done the fn to invoke upon completion. Invoked with (err, file).
   */
  parse: function(done) {
    var self = this;
    var imports = {};

    // Parse out all `@import 'filename';` statements:
    // TODO: use AST to handle this work.
    self.data = self.data.replace(/@import\s+?['"]([^'"]+)['"];?/g, function(match, filepath) {
      if (!imports[filepath]) {
        imports[filepath] = self.fork({file: filepath}).render(next);
      }
      return '__'+ filepath +'__';
    });

    // Continuation handler, invoked upon every imported file render:
    function next(err, file) {
      if (err) throw err;

      if (file) {
        // Swap in imported file data for import tokens:
        self.data = self.data.replace(new RegExp('__'+ file.file +'__', 'g'), file.data);
      }

      for (var i in imports) {
        // Abort if there are any pending imports:
        if (imports.hasOwnProperty(i) && !imports[i].isParsed()) return;
      }

      // Mark file as parsed and roll on:
      self._parsed = true;
      done(null, self);
    }

    // Invoke continuation immedaitely:
    // This assumes we might not need to import anything,
    // in which case we're already set to continue.
    next();
    return this;
  },

  /**
   * Forks a new file from the current file:
   * New file inherits all parent configuration,
   * with any provided overrides applied.
   * @param { Object } opts an object of override settings.
   * @return { File } new file object with forked config.
   */
  fork: function(opts) {
    return new File(extend({
      branch: this.branch.slice(),
      extensions: this.extensions,
      includePaths: this.includePaths,
      cwd: this.cwd,
      root: this.root
    }, opts));
  }
});

File.parse = function(opts, done) {
  return new File(opts).render(function(err, file) {
    // Callback:
    if (typeof done === 'function') done(err, file.data);

    // End event:
    if (err) file.emit('error', err);
    else file.emit('end', file.data);
  });
};

module.exports = File;