chai = require 'chai'

describe 'Checking Github PR', ->

  describe 'without any graphs', ->
    it 'should not post a diff'

  describe 'with unchecked graph changes', ->
    it 'should post a diff'

  describe 'with already checked changes', ->
    it 'should not post a diff'

  describe 'with new changes in graphs', ->
    it 'should post a new diff'

  describe 'with an added graph', ->
    it 'should post a new diff'

  describe 'with a removed graph', ->
    it 'should post a new diff'

  describe 'with non-graph .json', ->
    it 'should still post diffs for the graph .json files'
    it 'should post the error'

  describe 'with error in a graph', ->
    it 'should still post diffs for the rest'
    it 'should post the error'

  describe 'with unexpected error', ->
    it 'should post the error?'
