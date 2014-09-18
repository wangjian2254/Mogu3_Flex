// ActionScript file
import control.CBorderContainer;
import control.window.ChangePasswordPanel;
import control.window.UserInfoPanel;

import events.ChangeMenuEvent;
import events.ChangeUserEvent;
import events.QuiteEvent;

import flash.display.DisplayObject;

import model.User;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.components.Button;
import spark.components.TitleWindow;

import util.RightClickRegister;
import util.ToolUtil;

public function init():void {
    new RightClickRegister();
    Alert.yesLabel = "是";
    Alert.noLabel = "否";
    Alert.cancelLabel = "取消";

    if(this.hasOwnProperty("initAir")){
        this["initAir"]();
//        ChatManager.type="air";
    }
    if(this.hasOwnProperty("initFlex")){
        this["initFlex"]();

    }
	ToolUtil.currentUserFun = currentUser;
	//				ToolUtil.init();
	ToolUtil.sessionUserRefresh(currentUser);
	
	menuXML.send();
	FlexGlobals.topLevelApplication.addEventListener(ChangeMenuEvent.ChangeMenu_EventStr, changeMenu);
    FlexGlobals.topLevelApplication.addEventListener(QuiteEvent.Quite,logout);

	
}



private function currentUser(result:Object, e:ResultEvent):void {
	if (result.success) {
		if (!result.result) {
            // 没有登陆成功
			userinfoGroup.visible = false;
			userinfoGroup2.visible = true;
		} else {
            // 成功登陆
			userinfoGroup2.visible = false;
			userinfoGroup.visible = true;
//            ChatManager.loginChat();

		}
		menuXML.send();
		ToolUtil.init();
		for (var i:Number = 0; i < gongNengStack.numElements; i++) {
			var c:CBorderContainer = gongNengStack.getElementAt(i) as CBorderContainer;
			c.init(null);
		}
	}
}




private function iconFun(item:Object):Class {
	var xml:XML = item as XML;
	switch (xml.attribute('mod').toString()) {
		
		//					case 'guanLi3':
		//						return this.imgcz;
		//						break;
	}
	return null;
}

public function login():void {
	PopUpManager.addPopUp(ToolUtil.loginUser, FlexGlobals.topLevelApplication as DisplayObject, true);
	
}

public function reg():void {
    PopUpManager.addPopUp(ToolUtil.regUser, FlexGlobals.topLevelApplication as DisplayObject, true);
}

public function updateinfo():void {
	var changepassword:UserInfoPanel = UserInfoPanel(PopUpManager.createPopUp(
		this, UserInfoPanel, true) as TitleWindow);
	PopUpManager.centerPopUp(changepassword);
}

public function logout(e:*=null):void {
    ToolUtil.sessionUser=new User();
//    Pomelo.getIns().disconnect();
    if(e!=null){
        var evt:QuiteEvent = e as QuiteEvent;
        if(evt!=null){
            if(evt.needTip){
                if(this.hasOwnProperty("quite")){
                    this["quite"]();
                }
            }else{
                quiteNoTip();
            }
            return;
        }
    }
	if(this.hasOwnProperty("quite")){
		this["quite"]();
	}
	
}


public function repassword():void {
	var changepassword:ChangePasswordPanel = ChangePasswordPanel(PopUpManager.createPopUp(
		this, ChangePasswordPanel, true) as TitleWindow);
	PopUpManager.centerPopUp(changepassword);
	//				changepassword.x=(this.width-changepassword.width)/2;
	//				changepassword.y=(this.height-changepassword.height)/2;
}

public function searcher():void{
    Alert.show("搜索");
}


public function reLogin():void {
	FlexGlobals.topLevelApplication.dispatchEvent(new ChangeUserEvent(ChangeUserEvent.ChangeUser_EventStr, ToolUtil.sessionUser, true));
}