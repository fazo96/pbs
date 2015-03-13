#!/usr/bin/env coffee
chalk = require 'chalk'
cli = require 'commander'
fs = require 'fs'
Pert = require '../lib/pert.js'
express = require 'express'

ex = [{id: 0, depends: [], duration: 2}, { id: 1, depends: [0], duration: 3},{id: 2, depends: [0,1], duration: 4}]

cli
  .version '0.1'
  .description 'loads activity data from JSON and computes the possible activity delays'
  .usage '<command> [options] [args]'
  .option '-v, --verbose', 'be verbose (for debugging)'

didSomething = no

cli
  .command 'example'
  .description 'show an example of the JSON data format'
  .action ->
    pert = new Pert ex, cli.verbose
    didSomething = yes
    console.log chalk.bold.green('Before:'), ex
    console.log chalk.bold.green('After calculations:'), pert.calculate()
    console.log chalk.green 'Tip:',chalk.bold 'optional fields can be freely included in the input data'

cli
  .command 'calculate <file>'
  .description 'calculate data on given JSON document'
  .alias 'c'
  .option '-j, --json', 'output json data'
  .action (file,options) ->
    didSomething = yes
    fs.readFile file, (error,content) ->
      if error then err error
      else
        pert = new Pert JSON.parse(content), cli.verbose
        console.log pert.calculate options

cli
  .command 'graph <file>'
  .description 'serve HTTP GUI with pert graph of given JSON document'
  .alias 'g'
  .action (file) ->
    didSomething = yes
    fs.readFile file, (error,content) ->
      if error then err error
      else
        pert = new Pert JSON.parse(content), cli.verbose
        data = pert.calculate()
        app = express()
        app.use express.static 'client'
        app.get '/data', (req,res) -> res.json data
        app.listen 3000
        console.log chalk.green('Started Web Server'), 'on port', chalk.bold(3000)


cli.parse process.argv

if !didSomething then console.log chalk.green('Tip:'), 'see', chalk.bold(cli.name()+' --help')
