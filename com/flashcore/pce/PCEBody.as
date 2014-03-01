package com.flashcore.pce {
import flash.display.Bitmap;
import flash.events.EventDispatcher;
import flash.geom.Point;

public class PCEBody extends EventDispatcher {
		private var __cPEWrapper:PCEWrapper;
		public var linearVelocity:Point;
		public var prev:PCEBody;
		public var next:PCEBody;
		public var name:String;
		public var container:*;
        private var __nPreStepX:Number;
        private var __nPreStepY:Number;

		public function getWrapper():PCEWrapper {
			return __cPEWrapper;
		}

		public function PCEBody() {
			linearVelocity = new Point();

			var v : Number = Math.random();
			linearVelocity.x = v * 500;
			linearVelocity.y = (1 - v) * 500;
		}

		public function addBitmap(p_bitmap : Bitmap):void {
			__cPEWrapper = new PCEWrapper(p_bitmap);
			__cPEWrapper.invalidate();
		}

		public function checkContact(p_collider:PCECollider, p_time:Number):PCEContact {
            __nPreStepX = __cPEWrapper.object.x;
            __nPreStepY = __cPEWrapper.object.y;

			var lx : Number = linearVelocity.x * p_time;
			var ly : Number = linearVelocity.y * p_time;
			var ls : int = Math.round(Math.sqrt(lx * lx + ly * ly));

			var contact : PCEContact;
			for (var i : int = 0; i < ls; ++i) {
				__cPEWrapper.object.x = __nPreStepX + Math.round(i * lx / ls);
				__cPEWrapper.object.y = __nPreStepY + Math.round(i * ly / ls);

				contact = __cPEWrapper.checkContact(p_collider);
				if (contact != null) {
					contact.body = this;
					contact.collider = p_collider;
				}
				if (contact != null) {
					break;
                }
			}

			if (contact == null) {
				__cPEWrapper.object.x = Math.round(__nPreStepX + lx);
				__cPEWrapper.object.y = Math.round(__nPreStepY + ly);
			}

			return contact;
		}

		public function solveContact(p_contact:PCEContact, p_time:Number):void {
			var cos:Number = -p_contact.normal.x;
			var sin:Number = -p_contact.normal.y;
			var overlapCorrection:Number = Math.sqrt(p_contact.overlap.length * .5);

			var dt:Number = (overlapCorrection / linearVelocity.length) * p_time;

			var vx0:Number = linearVelocity.x * cos + linearVelocity.y * sin;
			var vy0:Number = linearVelocity.y * cos - linearVelocity.x * sin;
			vx0 *= -1;
			// vy0 *= 0.5;
			var nx:Number = vx0 * cos - vy0 * sin;
			var ny:Number = vy0 * cos + vx0 * sin;
			linearVelocity.x = nx;
			linearVelocity.y = ny;

            __cPEWrapper.object.x = Math.round(__cPEWrapper.object.x -cos * overlapCorrection + dt * linearVelocity.x);
            __cPEWrapper.object.y = Math.round(__cPEWrapper.object.y -sin * overlapCorrection + dt * linearVelocity.y);
		}
	}
}