# Pert

Pert is a small web app built to assist in working with Project Breakdown Structures.

It should be accessible [here](http://pert.divshot.io)

## Features

It's still in development.

- can calculate (almost) every info that can be retrieved from the minimum amount of data
- can draw a (almost correct and thorough) pert diagram
- can (almost) draw a timeline of the project

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

## Development

1. Clone the repo
2. make sure you have [gulp](http://gulpjs.com)
3. run `npm install && bower install && gulp` to build the project
4. the resulting static website is in `dist/`

## License

MIT
