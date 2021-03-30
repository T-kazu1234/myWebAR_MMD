fork
myWebAR_MMD
===
WebアプリでもMMDを踊らせたい

## Description
Web上にてARマーカーを使ってミクさんを踊らせるためのサンプルプログラム

Lat式ミクに"[地球最後の告白を](https://www5.atwiki.jp/hmiku/pages/22043.html)"を踊らせています

## Demo
* Youtube

    [![](https://img.youtube.com/vi/Gniowuje9W0/0.jpg)](https://www.youtube.com/watch?v=Gniowuje9W0)

* デモサイト
    
    [https://momijinn.github.io/myWebAR_MMD/](https://momijinn.github.io/myWebAR_MMD/)


## Requirement
* [three.js](https://threejs.org/)
* [AR.js](https://github.com/jeromeetienne/AR.js/blob/master/README.md)

## Usage
※ 著作権上、デフォルトでは音楽は流れません ※

※ 後述にて音楽を流せる方法を記載しておきます ※

1. GoogleChrome以外のブラウザ(MicoroSoft Edgeでは動作確認済み)にてIndex.htmlを開く

    ※上記のデモ用のURLではGoogleChromeでも開くことができます

2. Hiroマーカーをカメラに向けるとミクが踊っています

<br>

### 音楽を流す方法
1. "static/mmd/music/"に"[地球最後の告白を](https://www5.atwiki.jp/hmiku/pages/22043.html)"の音源をmusic.mp3にリネームして配置する

2. "staitc/js/index.js"にて,"new THREE.MMDLoader().loadWithAnimation"内に入っている音楽を再生する箇所のコメントアウトをはずす

    before
    ```javascript
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
    ```
    after
    ```javascript
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
        new THREE.AudioLoader().load(audioFile, function(buffer){
        var listener = new THREE.AudioListener();
        var audio = new THREE.Audio( listener ).setBuffer( buffer );

        listener.position.z = 1;
        
        helper.add( audio, audioParams );
        marker.add( listener );

        // Music Load Flag
        ready = true;
        });
        // ready = true; //ここのFlagをコメントアウトする


    }, onProgress, onError );
    ```

3. その後、キャッシュを削除し、Index.htmlを開き直すと音楽が流れる

## Licence
This software is released under the MIT License, see LICENSE.

<br>

本プログラムに使用しているMMD及びモーションは下記の再配布可能のものを利用しています

本プログラムに利用したMMDはLat様のLat式ミクを利用しています
```
製作者 ： Lat
yhblat@gmail.com
http://innoce.nobody.jp/
```

本プログラムに利用したモーションは[よぴ様](https://twitter.com/pyopi)の"【MMD】地球最後の告白を【モーショントレース】"を利用しています
```
製作者：よぴ
Twitter：@pyopi
Motion：https://www.nicovideo.jp/watch/sm25418510
```
