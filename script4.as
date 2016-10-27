/*

//===================================================================//

* RRRRRRR    IIIIII  MM     MM  VVV     VVV 
* RR  RRR      II    MMMMMMMMM   VV     VV 	
* RRRRR        II    MM MMM MM    VV   VV  	
* RR  RR       II    MM  M  MM     V   V   	
* RR   RR      II    MM     MM      VVV    	
* RR	RR   IIIIII  MM	    MM       V		

//===================================================================//


// 3D Interactive Art Gallery
// RimV: trieuduchien@gmail.com

*/


//________________________________________________________________________

package 
{

	//AS3
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	import flash.net.*;
	
	//Import  papervision 3D
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.*;
	import caurina.transitions.*;
	
	//  Main script4 class
	public class script4 extends MovieClip
	{
		//___________________________________________________________3d vars
		
		private var scene:MovieScene3D;
		private var camera:Camera3D;
		private var container:Sprite;
		private var camzoom:Number = 5;
							
		
		//__________________________________________________________Gallery vars
		
		private var numphot:Number = new Number(); // Number of photos
		private var radius:Number = 600;	
		private var cradius:Number = 1100;
		private var angle:Number = 0;
		private var anglePer:Number = new Number();
		private var anglePD:Number = new Number();
	
		//__________________________________________________________XML vars
		
		private var xmlLoader:URLLoader = new URLLoader();
		private	var xmlData:XML = new XML();
		private var xml_path:String = "data.xml";
		
		//__________________________________________________________Gallery Data
		
		private var thumb:Array = new Array();
		private var capt:Array = new Array();
		private var desc:Array = new Array();
		private var link:Array = new Array();
		private var img:Array = new Array();
		
		private var count:Number = 0;
		private var count2:Number = 0;
		private var tloaded:Number = 0;
		private var cID:Number = 0;			//	Current images
		private var lID:Number = 0;			// 	Last images
		private var pInfor:Dictionary = new Dictionary();
		private var	pContainer:Dictionary = new Dictionary();
		private var	imgInfor:Dictionary = new Dictionary();
		private var	ImgContainer:Array = new Array();
		
		// Plane infro
		private var planeDoubleSide:Boolean = false;
		private var planeSmooth:Boolean = true;
		private var quality:Number = 1;
		
		// Easing/Movement parameters
		private var mtime:Number = 1;		//duration movement of camera
		private var mtime2:Number = 1;		//duration movement of thumbnail when roll over
		private var mtime3:Number = 1.5;	//duration movement of thumbnail when pressed
		
		// Cam/Image easing type
		private var Cam_easeType:String = "easeOutQuint";
		private var Img_easeType:String = "easeOutQuint";
		private var Img_easeType2:String = "easeOutQuint";
		
		//Distance from origin position when moving out
		private var moveDistance:Number = 200; 
		
		// Auto rotate
		private var autorotate:Boolean = false;
		private var rotatespeed:Number = 0.002;
		private var rs:Number = 0.002;
		private var pitch:Number = 0.075;
		private var Pitch:Number = 0.075;
		
		// Alpha, transparency
		private var Alpha:Number = 1;
		
		// Reflection
		private var reflection:Boolean = true;
		private var refDist:Number = 180;  	//Distance from image to its corresponding reflection
		private var refIn1:Number = 0.5;	// Reflection Intensity 1
		private var refIn2:Number = 0;		// Reflection Intensity 2
		private var refDen1:Number = 0;		// Reflection Density 1
		private var refDen2:Number = 180;	// Reflection Density 2
		private var refSmooth:Boolean = false;	// Smooth Reflection
		private var refDoubleSide:Boolean = false;	// 2 side Reflection
		
		// Camera Infor
		private var COB:Object = new Object();
		private var camPos:Object = new Object();
		private var camHeight:Number = 0;
		
		private var tPos:Object = new Object();
		private var delta1:Number = 0.325;
		private var delta2:Number = 200;
		
		// Navigation Style
		private var nagStyle:String = "Mouse";
		
		// Descript4ion, Caption Data
		private var cTime:Number = 1; 	//Caption fade in, fade out
		private var dTime:Number = 1; 	//Descript4ion fade in, fade out
		private var cTrans:String = "linear"; 	//Transition type
		private var dTrans:String = "easeOutQuint";		//Transition type
		
		// StyleSheet
		var css:StyleSheet = new StyleSheet();
		
		// Misc variables
		private var flag:uint = 0;
		private var loaded:Boolean = false;
		private var big_loaded:Array = new Array();
		private var neededScale:Boolean = true;
		private var RollOvered:Boolean = false;
		private var rangle:Number = 0;
		
		//______________________________________________________________________Main script4
		//Constructor
		
		public function script4():void
		{
			// Block Papervison3D trace output
			Papervision3D.VERBOSE = false;
			
			// Initial 3d environment
			Init();
			
			// Create 3d gallery
			Create_gallery();
		
			// Initialize description , css, click event
			InitDescription();
		}
		
		// Setup data
		private function Init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Reposition element if stage is resized
			stage.addEventListener(	Event.RESIZE, rePosition)
			
			//Create container Sprite for scene 3d
			container = new Sprite();
			container.visible = false;
			addChild( container );
			// Movie Scene 3D
			scene = new MovieScene3D( container );
					
			// Camera 3D
			camera = new Camera3D();
			camera.zoom = camzoom;
			
			// Camera first position 
			camera.x = cradius;
			camera.z = 0;
			camera.y = camHeight;
			COB.angle = 0;
			camPos.angle = 0;
			
			// invisible descripton
			des.visible = false;
			
			// temporary remove caption, description to solve z order issue
			removeChild(cap);
			removeChild(des);
			
			// Setup preloader
			preloader.x = 0;
			preloader.y = (stage.stageHeight - preloader.height) * 0.5 ;
			preloader.width = stage.stageWidth;
			preloader.bar.scaleX = 0;
			
			container.x = stage.stageWidth * 0.5;
			container.y = stage.stageHeight * 0.5;
			
			// Reposition caption, description
			cap.x = (stage.stageWidth - cap.width) * 0.5 ;
			cap.y = container.y + 150;
			des.x = container.x ;
			des.y = (stage.stageHeight - des.height) * 0.5 + 20 ;
			
			prevbut.x = container.x - 390;
			nextbut.x = container.x + 370;
			prevbut.y = nextbut.y = container.y;
			
			prevbut.alpha = nextbut.alpha = 0;
			
			// for preview only
			Setup_link();
		}
		
		// Start to build gallery
		private function Create_gallery():void 
		{
			// Load data from XML
			XML_Loading();
			
			//Adding events, renderCamera
			this.addEventListener(Event.ENTER_FRAME, update3D);
		}
	
		
		//__________________________________________________________XML load 
		
		private function XML_Loading():void
		{
			xmlLoader.addEventListener(Event.COMPLETE, LoadXML);
			xmlLoader.load(new URLRequest( xml_path ));
		}
		
		private function LoadXML(e:Event):void 
		{
			//Extract data
			xmlData = new XML(e.target.data);
			ParseData(xmlData);
		}
		
		private function ParseData(dat:XML):void
		{
			//Number of photos
			numphot = dat.photos.photo.length();
			
			anglePer = (360/numphot) * Math.PI/180;
			anglePD = (360/numphot);
			
			// Add Enterframe event for preloader
			preloader.addEventListener(Event.ENTER_FRAME, preload);
			
			for (var i:uint = 0; i<numphot; i++)
			{
				thumb[i] = dat.photos.photo.thumb.attributes()[i];
				capt[i] = dat.photos.photo.caption.attributes()[i];
				desc[i] = dat.photos.photo.desc.text()[i];
				img[i] = dat.photos.photo.img.attributes()[i];
				big_loaded[i] = 0;
			}
			Load_thumbnail();
		}
			
		
		//Load external assest
		private function Load_thumbnail():void
		{
			for (var i:uint = 0; i<numphot; i++)
			{
				var myLoader:Loader = new Loader();
				var myRequest:URLRequest = new URLRequest(thumb[i]);
				myLoader.load(myRequest);
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, Thumb_loaded);
				pInfor[myLoader] = i;
			}
		}
		
		//Create gallery after load completed
		private function Thumb_loaded(e:Event):void
		{
			var myOb = e.target.loader;
			
			//Bitmap Material
			var bmp:BitmapData = new BitmapData( myOb.width, myOb.height, true, 0x000000 );
			bmp.draw(myOb);
			
			var bm:BitmapMaterial = new BitmapMaterial(bmp);
			bm.doubleSided = planeDoubleSide;
			bm.smooth = false;
			bm.name = "front";
			
			// Materials
			var materials:MaterialsList = new MaterialsList(
			{
				back:  new MovieAssetMaterial( "BACK", true ),
				front: bm
			} );
			
			var insideFaces  :int = Cube.FRONT + Cube.BACK;
	
			// Create a plane or cube with depth = 1
			var p:Cube= new Cube( materials, myOb.width, 1, myOb.height, quality, 1, quality, insideFaces );
	
			var index = pInfor[myOb];
			
			scene.addChild( p, "plane" + index );
					
			// Setting up the plane contains corresponding picture
			// Extracting the corresponding index
			
			// Additional data, for roll over, roll out movement purpose
			p.extra = {
				tPos:new Object,
				cPos:new Object,
				oPos:new Object,
				ref:new Plane(),
				index:new Number,
				rotationY:new Number
			}
			
			// Calculate origin position
			p.x = Math.cos( index * anglePer) * radius;
			p.z = Math.sin( index * anglePer) * radius;
			p.rotationY = ( -index * anglePer) * (180/Math.PI) + 270;
			
			p.extra.oPos.x = p.x;
			p.extra.oPos.z = p.z;
			
			p.extra.cPos.x = p.x;
			p.extra.cPos.z = p.z;
			
			p.extra.tPos.x = Math.cos( index * anglePer) * (radius + moveDistance);
			p.extra.tPos.z = Math.sin( index * anglePer) * (radius + moveDistance);
			
			p.extra.index = index;
			p.extra.rotationY = p.rotationY;
			
			count++;
			tloaded++;
			
			//Check if all thumbnails are loaded
			if (count == numphot)
			{
				//Load images
				for (var i:uint = 0; i < numphot; i++)
				{
					var myLoader:Loader = new Loader();
					var myRequest:URLRequest = new URLRequest(img[i]);
					myLoader.load(myRequest);
					myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, Img_loaded);
					imgInfor[myLoader] = i;
				}
				
				//Setting up Interactivities
				Interactive_setup();
				
				// Move first image to the front
				MovetoFront();
			}
			
			
			//______________________________________________________________Make Reflection
			if (reflection) 
			{
				// Create new reflection Bitmap Data 
				var bmp2:BitmapData = new BitmapData( myOb.width, myOb.height, true, 0x000000);
				
				// Flip vertical
				var m:Matrix = new Matrix();
				m.createBox(1, -1, 0, 0, myOb.height);
				bmp2.draw( bmp, m );
				
				//Reflection Bitmap Object
				var b2:Bitmap = new Bitmap(bmp2);
				
				// Reflection mask
				m.createGradientBox(myOb.width, myOb.height,Math.PI/2,myOb.height);
				var mymask:Shape = new Shape();
				mymask.graphics.lineStyle(0,0,0);
				mymask.graphics.beginGradientFill("linear", [0x000000, 0x000000],[refIn1, refIn2], [refDen1, refDen2],m) ;
				mymask.graphics.lineTo(0, myOb.height);
				mymask.graphics.lineTo(myOb.width, myOb.height);
				mymask.graphics.lineTo(myOb.width, 0)
				mymask.graphics.lineTo(0, 0)
				mymask.graphics.endFill();
				
				// CacheaAsBitmap
				mymask.cacheAsBitmap = true;
				b2.cacheAsBitmap = true;
				
				// Create mask
				b2.mask = mymask;
				
				addChild(b2);
				addChild(mymask);
				
				var bmp3:BitmapData = new BitmapData(myOb.width, myOb.height, true, 0x000000);
				bmp3.draw(b2);
				
				// Create Reflection plane
				var bm2:BitmapMaterial = new BitmapMaterial(bmp3);
				bm2.doubleSided = refSmooth;
				bm2.smooth = refDoubleSide;
				var p2:Plane = new Plane(bm2, 1, 0, 2, 2);
				
				p2.x = Math.cos( index * anglePer) * radius;
				p2.z = Math.sin( index * anglePer) * radius;
				p2.y = - refDist;
				p2.rotationY = ( -index * anglePer) * (180/Math.PI) + 270;
				
				scene.addChild(p2);
				removeChild(b2);
				removeChild(mymask);
				p.extra.ref = p2;
			}		
			
			//Sprite contains thumbnails
			var container:Sprite = p.container;
			
			// Setting Alpha value of thumbnails
			container.alpha = Alpha;
			pContainer[container] = p;
		}
		
		//___________________________________________________________Preloader
		
		private function preload(e:Event):void
		{
			var preloader = e.target;
			var bar = preloader.bar;
			bar.scaleX += (tloaded / (2 * numphot) - bar.scaleX) * 0.1;

			if (bar.scaleX >= 0.95) {
				bar.scaleX = 1;
				//Fade out preloader
				Tweener.addTween( preloader, {	alpha:0, 
								 				time:1, 
												transition:"easeOutExpo", 
												onComplete:function():void {
													
													//remove preloader ~ load complete
													removeChild(preloader)
													
													// Fade in screen
													container.visible = true;						
													container.alpha = 0;
													Tweener.addTween( container, {alpha:1, time:1, transition:"easeOutExpo" } );
													
													// Add caption, description
													addChild(cap);
													addChild(des);
												}
												});
				
				// remove Enterframe event for preloader
				preloader.removeEventListener(Event.ENTER_FRAME, preload);
				
				// Fade in prev, next button
				Tweener.addTween(prevbut,{alpha:1, time:1});
				Tweener.addTween(nextbut,{alpha:1, time:1});
				
			}
		}
		
		private function Img_loaded(e:Event):void
		{
			var img = e.target.loader;
			
			// Make reference for further using
			ImgContainer[imgInfor[img]] = img;
			
			//Scale down and hide image
			img.scaleX = 0;
			img.scaleY = 0;
			img.alpha = 0;
			addChild(img);	
			
			// increase total loaded
			tloaded++;
		}
				
		//________________________________________________________________Interactive Setup (Button)
		private function Interactive_setup():void
		{
			// Previous Button
			prevbut.buttonMode = true;
			prevbut.addEventListener(MouseEvent.MOUSE_DOWN, prePress);
			prevbut.addEventListener(MouseEvent.ROLL_OVER, preRollOver);
			prevbut.addEventListener(MouseEvent.ROLL_OUT, preRollOut);
			
			// Next Button
			nextbut.buttonMode = true;
			nextbut.addEventListener(MouseEvent.MOUSE_DOWN, nextPress);
			nextbut.addEventListener(MouseEvent.ROLL_OVER, nextRollOver);
			nextbut.addEventListener(MouseEvent.ROLL_OUT, nextRollOut);
		}
			
		private function prePress(e:Event):void
		{
			lID = cID;
			rangle -= anglePer;
			--cID;
			MoveCamera(rangle);
		}
		
		private function preRollOver(e:Event):void
		{
			var but = e.target;
			but.gotoAndPlay(2);
		}
		
		private function preRollOut(e:Event):void
		{
			var but = e.target;
			but.gotoAndPlay(46);
		}
		
		
		private function nextPress(e:Event):void
		{
			lID = cID;
			rangle += anglePer;
			++cID;
			MoveCamera(rangle);
		}
		
		private function nextRollOver(e:Event):void
		{
			var but = e.target;
			but.gotoAndPlay(2);
		}
		
		private function nextRollOut(e:Event):void
		{
			var but = e.target;
			but.gotoAndPlay(46);
		}
		
		//______________________________________________Thumbnail Roll Over, Roll Out, Press
		
		//Thumb roll over
		private function RollOver(e:Event):void
		{
			var p:Cube = pContainer[e.target];
			var ob:Object = {	x:p.extra.tPos.x,
								z:p.extra.tPos.z,
								time: mtime2,
								transition:Img_easeType,
								onUpdate: updatePos,
								onUpdateParams: [p]
							}
			Tweener.addTween(p.extra.cPos, ob );
			
			var index = p.extra.index;
			
			// Tween Caption:Fade In/Fade Out
			var FadeIn:Function = function(index:Number):void
			{
				cap.text = capt[index];
				Tweener.addTween(cap, {alpha:1, time: (cTime/2), transition:cTrans});
			}
			Tweener.addTween(cap, {alpha:0, time: (cTime/2) , transition:cTrans, onComplete: FadeIn, onCompleteParams:[index]});
		}
	
		// Thumb roll out	
		private function RollOut(e:Event):void
		{
			var p:Cube = pContainer[e.target];
			var ob:Object = {	x:p.extra.oPos.x,
								z:p.extra.oPos.z,
								time: mtime2,
								transition:Img_easeType,
								onUpdate: updatePos,
								onUpdateParams: [p]
							}
			Tweener.addTween(p.extra.cPos, ob );
		}
		
		
		// Thumb pressed
		private function Press(e:Event):void
		{
			var container = e.target;
			var p = pContainer[container];
				
			if (flag == 0) 
			{
				cap.alpha = 1;
				des.visible = true;
				
				for (var i:uint = 0; i < numphot; i++)
				{
					if ( i != p.extra.index) 
					{
						var pl = scene.getChildByName("plane"+i);
											
						//_____________________________________________________________________
						
						//Add tweening alpha - Optional
						Tweener.addTween(pl.container, {alpha:0, time:2, transition:"easeOutQuint"});
						Tweener.addTween(pl.extra.ref.container, {alpha:0, time:2, transition:"easeOutQuint"});
									
						//______________________________________________________________________
						
						//Add tweening scale - Optional
						/*
						Tweener.addTween(pl.container, {scaleX:0, scaleY:0, time:2, transition:"easeOutQuint"});
						Tweener.addTween(pl.extra.ref.container, {scaleX:0, scaleY:0, time:2, transition:"easeOutQuint"});
						*/
					}
				}
				
				var tob:DisplayObject3D = new DisplayObject3D();
				tob.x = delta1 * (1 - camera.x) + camera.x;
				tob.z = delta1 * (-camera.z) + camera.z;
				tob.rotationY = (-angle % 360) + 270;
				
				tob.moveLeft(delta2);
				tPos.x = tob.x;
				tPos.z = tob.z;
				tPos.rotationY = tob.rotationY;
				
				var myob:Object = {	x:tPos.x, 
									z:tPos.z, 
									y:0,
									rotationY:tPos.rotationY, 
									time:mtime3, 
									transition:Img_easeType2, 
									onUpdate:updatePos2, 
									onUpdateParams: [p]
									};
									
				// Move thumbnail to target position
				Tweener.addTween( p, myob);
				
				// Move Camera
				Tweener.addTween(camera, {y:0, time: dTime, transition:dTrans });
				
				//Fade In Descript4ion
				des.htmlText = desc[p.extra.index];

				Tweener.addTween(des, {alpha:1, time: dTime, transition:dTrans, onComplete:AddEvent, onCompleteParams:[p]});
				
				cID = p.extra.index;
			}
			else
			{
				container.removeEventListener(MouseEvent.ROLL_OVER, RollOver2);
				container.removeEventListener(MouseEvent.ROLL_OUT, RollOut2);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, MouseMove);
						
				prevbut.addEventListener(MouseEvent.MOUSE_DOWN, prePress);
				nextbut.addEventListener(MouseEvent.MOUSE_DOWN, nextPress);
				
				var myob2:Object = {x:p.extra.tPos.x, 
									z:p.extra.tPos.z, 
									y:0,
									rotationY:p.extra.rotationY, 
									time:mtime3, 
									transition:Img_easeType2, 
									onUpdate:updatePos2, 
									onUpdateParams: [p]
									};
									
				// Move thumbnail back
				Tweener.addTween( p, myob2);
				
				for (var j:uint = 0; j < numphot;   j++)
				{
					if ( j != p.extra.index) 
					{
						var pl2 = scene.getChildByName("plane"+j);
											
						//______________________________________________________________
						//Add tweening alpha - Optional
						
						Tweener.addTween(pl2.container, {alpha:1, time:2, transition:"easeOutQuint"});
						Tweener.addTween(pl2.extra.ref.container, {alpha:1, time:2, transition:"easeOutQuint"});
									
						//______________________________________________________________
						
						//Add tweening scale - Optional
						
						/*
						Tweener.addTween(pl2.container, {scaleX:1, scaleY:1, time:2, transition:"easeOutQuint"});
						Tweener.addTween(pl2.extra.ref.container, {scaleX:1, scaleY:1, time:2, transition:"easeOutQuint"});
						*/
					}
				}
				
				// Move Camera Back
				Tweener.addTween(camera, {y:camHeight, time: dTime, transition:dTrans });
				
				//Fade Out Descript4ion
				Tweener.addTween(des, {alpha:0, time: dTime, transition:dTrans, onComplete:function():void {des.visible = false}});
				
				//Fade Out image
				neededScale = true;
				Tweener.addTween(ImgContainer[cID], {scaleX:0, scaleY:0, alpha:0, time:1, transition:"easeOutQuint" });
			}
			flag = Math.abs(flag - 1);
		}
		
		//______________________________________________________________________
		// New roll over, roll out when a thumbnail is presed
		
		private function AddEvent(p:Cube):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, MouseMove);
			p.container.addEventListener(MouseEvent.ROLL_OVER, RollOver2);
			p.container.addEventListener(MouseEvent.ROLL_OUT, RollOut2
										 );
			// Also remove press event of prev/next btn
			prevbut.removeEventListener(MouseEvent.MOUSE_DOWN, prePress);
			nextbut.removeEventListener(MouseEvent.MOUSE_DOWN, nextPress);
		}
		
		private function RollOver2(e:Event):void
		{
			if (neededScale)
			{
				Tweener.addTween(ImgContainer[cID], {scaleX:1, scaleY:1, alpha:0.85, time:1, transition:"easeOutBack" });
				neededScale = false;
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, MouseMove);
		}
		
		private function RollOut2(e:Event):void
		{
			neededScale = true;
			Tweener.addTween(ImgContainer[cID], {scaleX:0, scaleY:0, alpha:0, time:1, transition:"easeOutQuint" });
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, MouseMove);
		}
		
		private function MouseMove(e:Event):void
		{
			ImgContainer[cID].x = (stage.mouseX + 10) ;
			ImgContainer[cID].y = (stage.mouseY + 10);
		}
		
		
		//_______________________________________________________________Update position 
		
		private function updatePos(p:Cube):void
		{
			p.x = p.extra.cPos.x;
			p.z = p.extra.cPos.z;
			p.extra.ref.x = p.x;
			p.extra.ref.z = p.z;
		}
		
		private function updatePos2(p:Cube):void
		{
			p.extra.cPos.x = p.x;
			p.extra.cPos.z = p.z;
			p.extra.ref.x = p.x;
			p.extra.ref.z = p.z;
			p.extra.ref.rotationY = p.rotationY;
		}
					
		//__________________________________________________________________Move camera to next position
			
		private function MoveCamera(an:Number):void
		{
			MovetoBack();
			camPos.angle = an;
			Tweener.addTween(COB, {angle: camPos.angle, time: mtime, transition:Cam_easeType, onUpdate:updateCamera, onComplete:MovetoFront});
		}
		
		private function MovetoFront():void
		{
			if (cID == numphot) cID = 0; 
				else
			if (cID == -1) cID = numphot - 1;
			
			var p = scene.getChildByName("plane" + cID);
			//Increase quality
			p.getMaterialByName("front").smooth = true;
			
			var ob:Object = {	x:p.extra.tPos.x,
								z:p.extra.tPos.z,
								time: mtime2,
								transition:Img_easeType,
								onUpdate: updatePos,
								onUpdateParams: [p]
							}
							
			Tweener.addTween(p.extra.cPos, ob );
			var index = p.extra.index;
			
			// Tween Caption:Fade In/Fade Out
			var FadeIn:Function = function(index:Number):void
			{
				cap.text = capt[index];
				Tweener.addTween(cap, {alpha:1, time: (cTime/2), transition:cTrans});
			}
			Tweener.addTween(cap, {alpha:0, time: (cTime/2) , transition:cTrans, onComplete: FadeIn, onCompleteParams:[index]});
			
			// Add press event to the front thumbnail
			var container = p.container;
			container.buttonMode = true;
			container.addEventListener(MouseEvent.MOUSE_DOWN, Press);		
		}
		
		private function MovetoBack():void
		{
			if (cID == numphot) cID = 0; 
				else
			if (cID == -1) cID = numphot - 1;
			
			var p = scene.getChildByName("plane" + lID);
			// Increase performance
			p.getMaterialByName("front").smooth = false;
			
			var ob:Object = {	x:p.extra.oPos.x,
								z:p.extra.oPos.z,
								time: mtime2,
								transition:Img_easeType,
								onUpdate: updatePos,
								onUpdateParams: [p]
							}
							
			Tweener.addTween(p.extra.cPos, ob );
			
			// Remove press event from the back thumbnail
			var container = p.container;
			container.buttonMode = false;
			container.removeEventListener(MouseEvent.MOUSE_DOWN, Press);		
		}
			
		private function updateCamera():void
		{
			var x = Math.cos( COB.angle) * cradius;
			var z = Math.sin( COB.angle) * cradius;
			camera.x = x;
			camera.z = z;
			angle = COB.angle * 180/Math.PI;
		}
		
		private function update3D(e:Event):void
		{
			scene.renderCamera( camera );
		}
		
		private function rePosition(e:Event):void
		{
			container.x = stage.stageWidth * 0.5;
			container.y = stage.stageHeight * 0.5;
			
			// Reposition caption, description
			cap.x = (stage.stageWidth - cap.width) * 0.5 ;
			cap.y = container.y + 150;
			des.x = container.x ;
			des.y = (stage.stageHeight - des.height) * 0.5 + 20 ;
			
			prevbut.x = container.x - 390;
			nextbut.x = container.x + 370;
			prevbut.y = nextbut.y = container.y;
		}
		
		//__________________________________________Apply styleSheet in description field
		
		private function InitDescription():void
		{
			// load external css
			var req:URLRequest = new URLRequest("css/styles.css");
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, cssLoaded);
			// Adding text link event
			addEventListener(TextEvent.LINK, clickText);
		}
		
		private function cssLoaded(e:Event):void
		{
			css.parseCSS(e.target.data);
			des.styleSheet = css;
		}
		
		private function clickText(li:TextEvent):void
		{
			var myURL:URLRequest = new URLRequest(li.text);
			navigateToURL(myURL,"_blank");
		}
		
		
		
		//___________________________________for Preview only
		
		private function Setup_link():void
		{
			gal.buttonMode = gal2.buttonMode = gal3.buttonMode = true;
			gal.addEventListener(MouseEvent.MOUSE_DOWN, go);
			gal2.addEventListener(MouseEvent.MOUSE_DOWN, go2);
			gal3.addEventListener(MouseEvent.MOUSE_DOWN, go3);
		}
		
		private function go(e:Event):void
		{
			var myURL:URLRequest = new URLRequest("./index.html");
			navigateToURL(myURL,"_self");
		}
	
		private function go2(e:Event):void
		{
			var myURL:URLRequest = new URLRequest("./3d2.html");
			navigateToURL(myURL,"_self");
		}

		private function go3(e:Event):void
		{
			var myURL:URLRequest = new URLRequest("./3d3.html");
			navigateToURL(myURL,"_self");
		}

	}
}
