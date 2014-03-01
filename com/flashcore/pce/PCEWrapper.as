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
			// Declare our collision return object
			var colliderBitmap:Bitmap = p_collider.bitmap;
			
			// Check if the is pixel collision between the 2 objects
			if (object.bitmapData.hitTest(new Point(Math.round(object.x), Math.round(object.y)), 1, colliderBitmap.bitmapData, new Point(colliderBitmap.x, colliderBitmap.y), 1))
			{
				// Transform target rectangle to where it collided with collider
				__rTargetRect.x = object.x - colliderBitmap.x;
				__rTargetRect.y = object.y - colliderBitmap.y;
				
				// Copy that part of collider into our collision data
				__bdCollisionData.copyPixels(colliderBitmap.bitmapData, __rTargetRect, ZERO_POINT);
				
				// Get rectangle bounds of pixels that we need so we don't need to use the whole bitmap
				__rCollisionRect = __bdCollisionData.getColorBoundsRect(0xFF000000, 0x0, false);
				// Extract those pixels into a vector
				__aCollisionVector = __bdCollisionData.getVector(__rCollisionRect);
				
				// Difference between the precached rectangle and collision rectangle
				var rectDif:int = Math.floor(__rTargetRect.width - __rCollisionRect.width),
					// This is pixel index in the target bitmap that corresponds to collision index in the rectangle fragment
					targetPixelIndex:int = Math.floor(__rCollisionRect.y * __rTargetRect.width + __rCollisionRect.x - rectDif),
					// Size of the collision vector
					collisionSize:int = __aCollisionVector.length,
					// Collision width
					collisionWidth:int = Math.floor(__rCollisionRect.width),
					// Overlap vector containing all the collision points
					overlap:Vector.<Point> = new Vector.<Point>(),
					// Collision position
					collisionPosition:int,
					// Collision normal
					collisionNormal:Point = new Point();
				
				// Iterate over the collision vector
				for (var i:int=0; i<collisionSize; i++)
				{
					// If we hit next row we need to offset the target pixel index
					if (i % collisionWidth == 0) targetPixelIndex += rectDif;
										
					// Check if the pixel is valid for normal calculation
					if ((__aCollisionVector[i] >> 24 & 0xFF) > ALPHA_TRESHOLD)
					{
						// Check if there is an overlap
						if((__aTargetVector[targetPixelIndex] >> 24 & 0xFF) > ALPHA_TRESHOLD)
						{
							overlap.push(new Point(targetPixelIndex % __bdCollisionData.width, targetPixelIndex / __bdCollisionData.width));
						}						
						
						// Calculate the horizontal collision coordinate
						collisionPosition = targetPixelIndex % __bdCollisionData.width;

						// We need to offset it if we are behind the center so its calculated equally on both sides
						if (collisionPosition >= __pTargetCenter.x) collisionPosition++;
						// Add it to normal horizontal coordinate
						collisionNormal.x += __pTargetCenter.x - collisionPosition;

						// Calculate the vertical collision coordinate
						collisionPosition = Math.floor(targetPixelIndex / __bdCollisionData.width);
						// We need to offset it if we are behind the center so its calculated equally on both sides
						if (collisionPosition >= __pTargetCenter.y) collisionPosition++;
						// Add it to normal vertical coordinate
						collisionNormal.y += __pTargetCenter.y - collisionPosition;
					}
					// Increase the target pixel index
					++targetPixelIndex;
				}
				collisionNormal.normalize(1);

				// Assign the collision data
				__cContact.normal = collisionNormal;
				__cContact.overlap = overlap;
                return __cContact;
			}
			
			return null;
		}
	}
}