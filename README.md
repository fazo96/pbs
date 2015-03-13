# Pert

Pert is a command line tool built to assist in the process of creating pert diagrams and calculating permitted delays.

## Installation

Make sure you have `node` and `npm` installed and working

__From git__

1. clone this repo
2. run `npm install` in the root of the repo, then run `bower install` in `client/` if you need to use the Web GUI
3. run `npm run-script build` to compile all files
4. the binary should now be in `bin/pert`

__From npm__

1. `npm install -g pert`
2. run `pert` in your shell

## Usage

    Usage: pert <command> [options] [args]

    loads activity data from JSON and computes the possible activity delays

    Commands:

      example                       show an example of the JSON data format
      calculate|c [options] <file>  calculate data on given JSON document
      graph|g <file>                serve HTTP GUI with pert graph of given JSON document

    Options:

      -h, --help     output usage information
      -V, --version  output the version number
      -v, --verbose  be verbose (for debugging)


This is the help information for the `pert calculate` command:

    Usage: calculate|c [options] <file>

    calculate data on given JSON document

    Options:

      -h, --help  output usage information
      -j, --json  output json data

## Data format

This is a valid input document (extra data is ignored but not thrashed):

```json
[
  {"id": 0, "duration": 3},
  {"id": 1, "duration": 1},
  {"id": 2, "duration": 2, "depends": [0]},
  {"id": 3, "duration": 5, "depends": [1]},
  {"id": 4, "duration": 5, "depends": [1]},
  {"id": 5, "duration": 2, "depends": [2,3,4]}
]
```

And this is the output of the `calculate` command on the previous document using the `--json` flag:

```json
[{"id":0,"duration":3,"startDay":0,"endDay":3,"permittedDelay":0},{"id":1,"duration":1,"startDay":0,"endDay":1,"permittedDelay":0},{"id":2,"duration":2,"depends":[0],"startDay":3,"endDay":5,"permittedDelay":1},{"id":3,"duration":5,"depends":[1],"startDay":1,"endDay":6,"permittedDelay":0},{"id":4,"duration":5,"depends":[1],"startDay":1,"endDay":6,"permittedDelay":0},{"id":5,"duration":2,"depends":[2,3,4],"startDay":6,"endDay":8}]
```

## License

MIT
