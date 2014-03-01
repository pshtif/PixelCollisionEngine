package com.flashcore.pce {
    /**
	 * @author sHTiF
	 */
	public class PCEWorld {
		
		private var __cContactManager:PCEContactManager;
		
		private var __cBodyList:PCEBody;
		private var __iBodyCount:int = 0;
		
		private var __cColliderList:PCECollider;
		private var __iColliderCount:int = 0;
		
		public function PCEWorld() {
			__cContactManager = new PCEContactManager();
		}
		
		public function addBody(p_body:PCEBody):void {
			p_body.prev = null;
			p_body.next = __cBodyList;
			if (__cBodyList) {
				__cBodyList.prev = p_body;
			}
			__cBodyList = p_body;
			++__iBodyCount;
		}
		
		public function addCollider(p_collider:PCECollider):void {
			p_collider.prev = null;
			p_collider.next = __cColliderList;
			if (__cColliderList) {
				__cColliderList.prev = p_collider;
			}
			__cColliderList = p_collider;
			++__iColliderCount;
		}
		
		public function update(p_time:Number):void {
			__cContactManager.clear();
			
			for (var body:PCEBody = __cBodyList; body; body=body.next) {
				var contact:PCEContact = body.checkContact(__cColliderList, p_time);
				if (contact!=null) contact.solve(p_time);
				/*
				for (var collider:PECollider = __cColliderList; collider; collider=collider.next) {
					var contact:PEContact = body.checkContact(collider);
					if (contact!=null) contact.solve(p_time);
				}
				/**/
			}
		}
	}
}
