package com.flashcore.pce {

	/**
	 * @author sHTiF
	 */
	public class PCEContactManager {
		
		private var __cContactList:PCEContact;
		
		public function clear():void {
			__cContactList = null;
		}
		
		public function addContact(p_contact:PCEContact):void {
			p_contact.prev = null;
			p_contact.next = __cContactList;
			if (__cContactList)	{
				__cContactList.prev = p_contact;
			}
			__cContactList = p_contact;
		}
		
		public function resolve():void {
			for (var contact:PCEContact; contact; contact=contact.next) {
				//contact.solve();
			}
		}
	}
}
