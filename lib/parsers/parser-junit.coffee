###
Reads PHPUnit test results to determine the coverage percentage.

@author Roelof Roos (https://github.com/roelofr)
###

path = require 'path'
fs = require 'fs'
ParserBase = require './parser-base'

module.exports =
class ParserJunit extends ParserBase

    resultFile: null
    resultData: null

    constructor: (file) ->
        if typeof file != 'string'
            console.warn 'Tried to use non-string as file!', file
            return

        # Always make sure the file exists and is a file!
        try
            fileStat = fs.statSync file

            # Log non-files to the console
            if fileStat and fileStat.isFile()
                @resultFile = file
            else
                console.warn "Tried to use non-existent or non-file #{file}!"

        catch err
            # Log errors!
            console.warn "Failed to read file #{file}: ", err
            return

    ###
    Reads the config file if it hasn't been done already.

    @param {Function} callback `func(error, data)`
    @return {Boolean} true if reading, false if reading isn't possible
    @visibility private
    ###
    read: (callback) ->
        if typeof callback != 'function' then return false
        if @resultFile == null then return false

        if @resultData != null
            callback null, @resultData
            return true

        super @resultFile, (err, data) =>
            if err
                callback err, null
            else
                @resultData = data
                callback null, @resultData

    ###
    Reads the test results and returns a test coverage percentage

    @param {Function} callback after read has completed, gets an array
    @return array List of suite names. Null on error
    ###
    getStatistics: (callback) ->
        if typeof callback != 'function' then return false

        @read (err, data) =>
            if err != null
                console.warn "Failed to read data:", err
                return callback null

            tests = 0
            errors = 0
            failures = 0

            # Find all tests
            for metric in data.find '//testsuite'
                if metric.attr('tests')?
                    tests += Number metric.attr('tests').value()
                if metric.attr('failures')?
                    errors += Number metric.attr('errors').value()
                if metric.attr('errors')?
                    failures += Number metric.attr('failures').value()

            callback {
                tests: tests,
                errors: errors,
                failures: failures
            }
