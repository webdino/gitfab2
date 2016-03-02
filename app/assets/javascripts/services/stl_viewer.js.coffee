class StlViewer
  constructor: (url, width, height) ->
    @url = url
    @width = width
    @height = height
    @show()
  show: ->
    container = document.createElement 'div'
    $("li[data-stl='" + @url + "']").append container

    @camera = new THREE.PerspectiveCamera(35, @width / @height, 1, 15)
    @camera.position.set(3, 0.15, 3)
    @cameraTarget = new THREE.Vector3(0, -0.25, 0)

    @scene = new THREE.Scene()
    @scene.fog = new THREE.Fog(0xE3F6FF, 2, 15)

    loader = new THREE.STLLoader()
    material = new THREE.MeshPhongMaterial
      color: 0xffffff
      specular: 0x111111
      shininess: 200

    loader.load @url, (geometry) =>
      mesh = new THREE.Mesh geometry, material
      mesh.position.set(0.136, - 0.37, - 0.6)
      mesh.rotation.set(- Math.PI / 2, 0.3, 0)
      mesh.scale.set(1, 1, 1)
      mesh.castShadow = true
      mesh.receiveShadow = true
      @scene.add mesh

    @scene.add new THREE.HemisphereLight(0xffffff, 0x000000)

    @renderer = new THREE.WebGLRenderer {antialias: true}
    @renderer.setClearColor @scene.fog.color
    @renderer.setPixelRatio window.devicePixelRatio
    @renderer.setSize @width, @height

    @renderer.gammaInput = true
    @renderer.gammaOutput = true
    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.cullFace = THREE.CullFaceBack

    container.appendChild @renderer.domElement
    @camera.lookAt @cameraTarget
    @animate()

  animate: =>
    requestAnimationFrame @animate
    @render()

  render: =>
    timer = Date.now() * 0.0005
    @camera.position.x = Math.cos(timer) * 3
    @camera.position.z = Math.sin(timer) * 3
    @camera.lookAt @cameraTarget
    @renderer.render @scene, @camera

$ ->
  $("li[data-stl]").each ->
    if $(this).closest(".annotation").length > 0
      width = 300
      height = 300
    else
      width = 380
      height = 380
    url = $(this).data("stl")
    new StlViewer url, width, height
