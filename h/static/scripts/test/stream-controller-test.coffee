{module, inject} = require('angular-mock')

assert = chai.assert
sinon.assert.expose assert, prefix: null


describe 'StreamController', ->
  $controller = null
  $scope = null
  fakeAnnotationMapper = null
  fakeParams = null
  fakeQueryParser = null
  fakeRoute = null
  fakeStore = null
  fakeStreamer = null
  fakeStreamFilter = null
  fakeThreading = null

  sandbox = null

  createController = ->
    $controller('StreamController', {$scope: $scope})

  before ->
    angular.module('h', [])
    .controller('StreamController', require('../stream-controller'))

  beforeEach module('h')

  beforeEach module ($provide) ->
    sandbox = sinon.sandbox.create()

    fakeAnnotationMapper = {
      loadAnnotations: sandbox.spy()
    }

    fakeParams = {id: 'test'}

    fakeQueryParser = {
      populateFilter: sandbox.spy()
    }

    fakeRoute = {
      reload: sandbox.spy()
    }

    fakeSearchFilter = {
      generateFacetedFilter: sandbox.stub()
      toObject: sandbox.stub().returns({})
    }

    fakeStore = {
      SearchResource: {
        get: sandbox.spy()
      }
    }

    fakeStreamer = {
      open: sandbox.spy()
      close: sandbox.spy()
      send: sandbox.spy()
    }

    fakeStreamFilter = {
      resetFilter: sandbox.stub().returnsThis()
      setMatchPolicyIncludeAll: sandbox.stub().returnsThis()
      getFilter: sandbox.stub()
    }

    fakeThreading = {
      createIdTable: sandbox.spy()
    }

    $provide.value 'annotationMapper', fakeAnnotationMapper
    $provide.value '$route', fakeRoute
    $provide.value '$routeParams', fakeParams
    $provide.value 'queryParser', fakeQueryParser
    $provide.value 'searchFilter', fakeSearchFilter
    $provide.value 'store', fakeStore
    $provide.value 'streamer', fakeStreamer
    $provide.value 'streamFilter', fakeStreamFilter
    $provide.value 'threading', fakeThreading
    return

  beforeEach inject (_$controller_, $rootScope) ->
    $controller = _$controller_
    $scope = $rootScope.$new()
    $scope.sort = {}

  afterEach ->
    sandbox.restore()

  it 'disables page search by shadowing the search field', ->
    createController()
    assert.match($scope.search, {})

  it 'resets the threading service', ->
    createController()
    assert.calledOnce(fakeThreading.createIdTable)
    assert.calledWith(fakeThreading.createIdTable, [])
    assert.isObject(fakeThreading.root)
    assert.strictEqual(fakeThreading.root, $scope.threadRoot)

  describe 'on $routeUpdate', ->

    it 'reloads the route when the query changes', ->
      fakeParams.q = 'test query'
      createController()
      fakeParams.q = 'new query'
      $scope.$broadcast('$routeUpdate')
      assert.calledOnce(fakeRoute.reload)

    it 'does not reload the route when the query is the same', ->
      fakeParams.q = 'test query'
      createController()
      $scope.$broadcast('$routeUpdate')
      assert.notCalled(fakeRoute.reload)
