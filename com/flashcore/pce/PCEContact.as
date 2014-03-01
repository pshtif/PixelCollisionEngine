package com.flashcore.pce {
	import flash.geom.Point;

	public class PCEContact	{
		public var prev:PCEContact;
		public var next:PCEContact;
		
		public var body:PCEBody;
		public var collider:PCECollider;
		
		public var normal:Point;
		public var overlap:Vector.<Point>;
		
		public function PCEContact(p_body:PCEBody = null, p_collider:PCECollider = null, p_normal:Point = null, p_overlap:Vector.<Point> = null) {
			body = p_body;
			collider = p_collider;
			
			normal = p_normal;
			overlap = p_overlap;
		}
		
		public function solve(p_time:Number):void {
			body.solveContact(this, p_time);
		}
	}
}