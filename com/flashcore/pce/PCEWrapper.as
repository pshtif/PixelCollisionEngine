package com.flashcore.pce {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Peter "sHTiF" Stefcek / http://blog.flash-core.com 
	 */
	public class PCEWrapper
	{
		static private const ZERO_POINT:Point = new Point();
		static public const ALPHA_TRESHOLD:int = 0;
		
		private var __bdCollisionData:BitmapData;
		private var __aCollisionVector:Vector.<uint>;
		private var __rCollisionRect:Rectangle;
		
		private var __aTargetVector:Vector.<uint>;
		private var __rTargetRect:Rectangle;
		private var __pTargetCenter:Point;
        private var __cContact:PCEContact;
		
		public var object:Bitmap;
		
		public function PCEWrapper(p_object:Bitmap) {
			object = p_object;
            __cContact = new PCEContact();
		}
		
		public function invalidate():void {
			__bdCollisionData = new BitmapData(object.width, object.height, true, 0x0);
			
			__aTargetVector = object.bitmapData.getVector(object.bitmapData.rect);
			__pTargetCenter = new Point(__bdCollisionData.width >> 1, __bdCollisionData.height >> 1);
			__rTargetRect = new Rectangle(0,0,object.width, object.height);
		}
		
		public function checkContact(p_collider:PCECollider):PCEContact {
			var colliderBitmap:Bitmap = p_collider.bitmap;

			if (object.bitmapData.hitTest(new Point(Math.round(object.x), Math.round(object.y)), 1, colliderBitmap.bitmapData, new Point(colliderBitmap.x, colliderBitmap.y), 1))
			{
				__rTargetRect.x = object.x - colliderBitmap.x;
				__rTargetRect.y = object.y - colliderBitmap.y;
				
				__bdCollisionData.copyPixels(colliderBitmap.bitmapData, __rTargetRect, ZERO_POINT);
				
				__rCollisionRect = __bdCollisionData.getColorBoundsRect(0xFF000000, 0x0, false);
				__aCollisionVector = __bdCollisionData.getVector(__rCollisionRect);
				
				var rectDif:int = int(__rTargetRect.width - __rCollisionRect.width),
					targetPixelIndex:int = Math.floor(__rCollisionRect.y * __rTargetRect.width + __rCollisionRect.x - rectDif),
					collisionSize:int = __aCollisionVector.length,
					collisionWidth:int = Math.floor(__rCollisionRect.width),
					overlap:Vector.<Point> = new Vector.<Point>(),
					collisionPosition:int,
					collisionNormal:Point = new Point();
				
				for (var i:int=0; i<collisionSize; i++)
				{
					if (i % collisionWidth == 0) targetPixelIndex += rectDif;
										
					if ((__aCollisionVector[i] >> 24 & 0xFF) > ALPHA_TRESHOLD)
					{
						if((__aTargetVector[targetPixelIndex] >> 24 & 0xFF) > ALPHA_TRESHOLD)
						{
							overlap.push(new Point(targetPixelIndex % __bdCollisionData.width, targetPixelIndex / __bdCollisionData.width));
						}						
						
						collisionPosition = targetPixelIndex % __bdCollisionData.width;

						if (collisionPosition >= __pTargetCenter.x) collisionPosition++;
						collisionNormal.x += __pTargetCenter.x - collisionPosition;

						collisionPosition = Math.floor(targetPixelIndex / __bdCollisionData.width);
						if (collisionPosition >= __pTargetCenter.y) collisionPosition++;
						collisionNormal.y += __pTargetCenter.y - collisionPosition;
					}
					++targetPixelIndex;
				}
				collisionNormal.normalize(1);

				__cContact.normal = collisionNormal;
				__cContact.overlap = overlap;
                return __cContact;
			}
			
			return null;
		}
	}
}