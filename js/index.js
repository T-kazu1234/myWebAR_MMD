var mesh, camera, scene, renderer, effect;
var helper;

var ready = false;

var context;
var source;
var controls, marker;

var audio;

var clock = new THREE.Clock();

init();
// renderScene();

function init() {
  //three.jsの設定
  
  //シーンの新規作成(init)
  scene = new THREE.Scene();

  //レンダーの設定
  renderer = new THREE.WebGLRenderer({ antialias: true,alpha: true});
  
  renderer.setPixelRatio( window.devicePixelRatio );
  renderer.setSize( window.innerWidth, window.innerHeight );

  renderer.domElement.style.position = "absolute";
  document.body.appendChild(renderer.domElement);

  effect = new THREE.OutlineEffect( renderer );


  //cameraの作成
  camera = new THREE.Camera();
  scene.add(camera);

  //Lightの作成
  var light = new THREE.DirectionalLight( 0xffffff);
  light.position.set( -20, 20, 20 );
  scene.add( light );


  //リサイズ関数
  function onResize(){
    source.onResizeElement();
    source.copyElementSizeTo(renderer.domElement);

    if(context.arController !== null){
      source.copyElementSizeTo(context.arController.canvas);
    }
  }
  
  
  //マーカートラッキングの設定
  source = new THREEx.ArToolkitSource({
    sourceType: "webcam",
  });
  source.init(function onReady() {
    onResize();
  });

  //arToolkitContext(カメラparametaer,マーカー検出設定)
  context = new THREEx.ArToolkitContext({
    debug: false,
    cameraParametersUrl:  THREEx.ArToolkitContext.baseURL + '../data/data/camera_para.dat',
    detectionMode: "mono", 
    imageSmoothingEnabled: true,
    maxDetectionRate: 60,
    canvasWidth: source.parameters.sourceWidth, 
  });

  context.init(function onCompleted(){
    camera.projectionMatrix.copy(context.getProjectionMatrix());
  });


  //リサイズ処理
  window.addEventListener("resize", function() { 
    onResize();
  });


  //マーカーの設定
  marker = new THREE.Group();
  controls =  new THREEx.ArMarkerControls(context, marker, {
    barcodeValue:"Hiro",
    type: "pattern",
    patternUrl: THREEx.ArToolkitContext.baseURL+'examples/marker-training/examples/pattern-files/pattern-hiro.patt'
  });
  scene.add(marker);

  // mmd Load
  function onProgress( xhr ) {
    if ( xhr.lengthComputable ) {
      var percentComplete = xhr.loaded / xhr.total * 100;
      console.log( Math.round( percentComplete, 2 ) + '% downloaded' );
    }
  };
    
  function onError( xhr ) {
  };
    
  /* pmd, vmd File */
//var modelFile = './mmd/pmd/Lat式ミクVer2.31_Sailor夏服エッジ無し専用.pmd'; //エッジ無しverにしないと描画が変になる
  var modelFile = './mmd/pmd/111友希あいね.pmd'; //エッジ無しverにしないと描画が変になる
  
  var vmdFiles = ['./mmd/vmd/地球最後の告白を_Latミクv2.31S_b.vmd'];

  /* Music File */
  var audioFile = './mmd/music/music.mp3';
  var audioParams = { delayTime: 0 };

  
  
  helper = new THREE.MMDAnimationHelper( {
    afterglow: 2.0
  });
    
  new THREE.MMDLoader().loadWithAnimation( modelFile, vmdFiles, function ( mmd ) {
    mesh = mmd.mesh;

    // 3dobject
    var model = new THREE.Object3D();
    // Scaleの変換
    model.scale.x = 0.1;
    model.scale.y = 0.1;
    model.scale.z = 0.1;
    model.add(mesh);

    helper.add( mesh, {
      animation: mmd.animation,
      physics: true,
    });

    //add maker
    marker.add(model);
    
    //Audio
    // new THREE.AudioLoader().load(audioFile, function(buffer){
    //   var listener = new THREE.AudioListener();
    //   var audio = new THREE.Audio( listener ).setBuffer( buffer );

    //   listener.position.z = 1;
      
    //   helper.add( audio, audioParams );
    //   marker.add( listener );

    //   // Music Load Flag
    //   ready = true;
    // });
    ready = true;


  }, onProgress, onError );
}


//Render
// function renderScene() {
//   requestAnimationFrame(renderScene);
//   if(source.ready === false){ return; }

//   context.update(source.domElement);
  
//   if(ready){
//     helper.update(clock.getDelta());
//   }

//   // renderer.render( scene, camera );
//   effect.render( scene, camera );
// }

setInterval(function(){
  if(source.ready === false){ return; }

  if(ready){
    helper.update(clock.getDelta());
  }

  renderer.render( scene, camera );
  context.update(source.domElement);
}, 1000 / 60); //60fps
