package util
{
import control.window.JoinOrgPanel;
import control.window.LoginUserPanel;
import control.window.RegisterUserPanel;
import control.window.SelectOrgPanel;

import events.ChangeScheduleEvent;
import events.ChangeUserEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

import httpcontrol.CHTTPService;
import httpcontrol.HttpServiceUtil;

import model.User;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public class ToolUtil
{
    public function ToolUtil()
    {
    }

    [Bindable]
    public static var resultMsg:String="";

    public static var joinOrgFlag:String;

    public static var  currentUserFun:Function=null;
    public static var loginUser:LoginUserPanel= new LoginUserPanel();
    public static var regUser:RegisterUserPanel= new RegisterUserPanel();
    public static var selectOrg:SelectOrgPanel= new SelectOrgPanel();
    public static var searchOrg:JoinOrgPanel= new JoinOrgPanel();

    public static var projectstatus:ArrayCollection=new ArrayCollection([{id:"unstart",label:"未开始"},{id:"runing",label:"正在进行"},{id:"finished",label:"已完成"},{id:"closed",label:"已关闭"}]);
    public static var taskstatuslist:ArrayCollection=new ArrayCollection([{id:1,label:"未开始"},{id:2,label:"正在进行"},{id:3,label:"待审核"},{id:4,label:"完成"}]);
    public static var taskurgentlist:ArrayCollection=new ArrayCollection([{id:1,label:"普通"},{id:2,label:"优先"},{id:3,label:"紧急"}]);


    public static var kindTypeList:ArrayCollection=new ArrayCollection([{id:'0',label:"管理员专用"},{id:'1',label:"第三方可用"}]);




    private static var time:Timer = new Timer(1000*60*5,0);

    public static function init():void{

        loginUser = new LoginUserPanel();
        regUser = new RegisterUserPanel();
        selectOrg = new SelectOrgPanel();


        sessionUserRefresh();
        kindListRefresh();
//        currentOrgRefresh();
//        departMentListRefresh();
//        contactsRefresh();
//        allProjectListRefresh();
//        projectListRefresh();
//			taskRefresh();
//        taskUnRefresh();

//        unreadMessageRefresh();
        time.addEventListener(TimerEvent.TIMER,unreadMessageRefresh);
        if(!time.running){
//            time.start();
        }
//			ruleRefresh();
//			ticketRefresh();
//			businessRefresh();
//			kmRefresh();
    }


    [Bindable]
    public static var sessionUser:User=new User();


    public static function sessionUserRefresh(fun:Function=null):void{
//			RemoteUtil.getOperationAndResult("getAllUser",resultAllUser).send();
        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/currentUser",resultFinduser,"POST").send()
//				RemoteUtil.getOperationAndResult("",resultAllUser,false).send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResultAndFault("/currentUser",resultFinduser,failueFinduser,"POST");

            http.resultFunArr.addItem(fun);
            http.send();

        }
    }
    public static function resultFinduser(result:Object,e:ResultEvent):void{
        if(result.success==true){
            if(sessionUser==null||sessionUser["uid"]!=result.result["uid"]){
                FlexGlobals.topLevelApplication.dispatchEvent(new ChangeUserEvent(ChangeUserEvent.ChangeUser_EventStr,result.result,true));
            }
//            var u:User = new User();
            sessionUser.username = result.result.username;
            sessionUser.name = result.result.name;
            sessionUser.uid = result.result.uid;
            sessionUser.auth = result.result.auth;
            if(sessionUser.auth == 'admin'){
                pluginRefresh();
            }
//            sessionUser=u;
        }else{
            sessionUser=new User();
        }
    }

    public static function failueFinduser(e:FaultEvent):void{

    }



    [Bindable]
    public static var unreadMessageNum:String="0未读消息";

    public static function unreadMessageRefresh(fun:*=null):void{
//			RemoteUtil.getOperationAndResult("getAllUser",resultAllUser).send();
        if(fun==null||!(fun is Function)){
            HttpServiceUtil.getCHTTPServiceAndResult("/oamessage/getUnReadCount",resultUnReadMessageRefresh,"POST").send()
//				RemoteUtil.getOperationAndResult("",resultAllUser,false).send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/oamessage/getUnReadCount",resultUnReadMessageRefresh,"POST");
            http.resultFunArr.addItem(fun);
            http.send();
        }
    }
    public static function resultUnReadMessageRefresh(result:Object,e:ResultEvent):void{
        if(result.success==true){
            unreadMessageNum = result.result+"未读消息";
        }
    }


    [Bindable]
    public static var allkindlist:ArrayCollection=new ArrayCollection();
    [Bindable]
    public static var userkindlist:ArrayCollection=new ArrayCollection();

    public static function kindListRefresh(fun:Function=null):void{

        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/KindList", resultGetKindlist,"POST").send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/KindList", resultGetKindlist,"POST");
            http.resultFunArr.addItem(fun);
            http.send();

        }

    }
    public static function resultGetKindlist(result:Object,e:ResultEvent):void{
        var l:ArrayCollection = new ArrayCollection(result.result as Array);
        allkindlist.removeAll();
        userkindlist.removeAll();
        for each(var item:Object in l){
            if(item.type == '1'){
                userkindlist.addItem(item);
            }
            allkindlist.addItem(item);
        }
    }

    public static function initMyDepart(mydepartlist:ArrayCollection):ArrayCollection{
        // 将有包含关系的部门，排序，形成缩进效果

        var departmentlist:ArrayCollection=new ArrayCollection();
        var depart:Object = new Object();
        var rootDepart:Object = null;
        for each(var item:Object in mydepartlist) {
            depart['d' + item.id] = item;
            if (!item.father) {
                rootDepart = item;
                item.level = 0;
                item.space ="";
                item.label = item.space+item.name;
            }
            item.children = new ArrayCollection();
        }
        findDepartByFather(rootDepart,mydepartlist);
        for each(item in mydepartlist) {
            if (item.father) {
//                item.level = depart['d' + item.father].level + 1;
                if (!depart['d' + item.father].hasOwnProperty('dep_children')) {
                    depart['d' + item.father].dep_children = new ArrayCollection();
                }
                depart['d' + item.father].dep_children.addItem(item);
            }
            item.children.addAll(new ArrayCollection(item.members as Array));
        }
        for each(item in mydepartlist) {
            if (item.flag == 'free') {
                depart['d' + item.father].dep_children.removeItemAt(depart['d' + item.father].dep_children.getItemIndex(item));
                depart['d' + item.father].dep_children.addItem(item);
            }
        }

        if(rootDepart!=null){
            departmentlist.addItem(rootDepart);
            showDepartChildren_handler(rootDepart,departmentlist);
        }
        return departmentlist;
    }

    public static function findDepartByFather(father:Object,mydepartlist:ArrayCollection):void{
        for each(var item:Object in mydepartlist){
            if(item.father==father.id){
                item.level = father.level+1;
                item.space = father.space+" ";
                item.label = item.space+item.name;
                findDepartByFather(item,mydepartlist);
            }
        }
    }

    private static function showDepartChildren_handler(depart:Object,departmentlist:ArrayCollection):void {
        var index:int = 0;
        for (var i:int = 0; i < departmentlist.length; i++) {
            if (depart.id == departmentlist.getItemAt(i).id) {
                index = i;
                break;
            }
        }
        if (depart.hasOwnProperty('dep_children')){
            if (index == departmentlist.length - 1 && departmentlist.length != 1) {
                departmentlist.addAll(depart.dep_children);
            } else {
                departmentlist.addAllAt(depart.dep_children, index + 1);
            }
            for each(var d:Object in depart.dep_children){
                showDepartChildren_handler(d,departmentlist);
            }
        }



    }

    private static function getMemberlistByMy (mydepartlist:ArrayCollection,l0:ArrayCollection):ArrayCollection{
        var l:ArrayCollection=new ArrayCollection();
        var f:Boolean=false;
        for each(var d:Object in l0){
            if(d.flag=='free'){
                continue;
            }
            f=true;
            for each(var m:Object in mydepartlist){
                if(d.father==m.id){
                    for each(var m2:Object in mydepartlist){
                        if(m2.id==d.id){
                            f=false;
                        }
                    }
                    if(f){
                        l.addItem(d);
                    }

                }
            }
        }
        if(l.length>0){
            var l2:ArrayCollection=getMemberlistByMy(l,l0);
            l.addAll(l2);
        }
        return l;
    }


    [Bindable]
    public static var groupList:ArrayCollection=new ArrayCollection();

    [Bindable]
    public static var projectList:ArrayCollection=new ArrayCollection();

    public static function projectListRefresh(fun:Function=null):void{

        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/ca/get_my_project",resultProjectList,"POST").send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/ca/get_my_project",resultProjectList,"POST");
            http.resultFunArr.addItem(fun);
            http.send();

        }

    }
    public static function resultProjectList(result:Object,e:ResultEvent):void{
        if(result.success==true){
            projectList.removeAll();
            projectList.addAll(new ArrayCollection(result.result as Array));

        }
    }

    [Bindable]
    public static var allProjectList:ArrayCollection=new ArrayCollection();

    public static function allProjectListRefresh(fun:Function=null):void{

        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/ca/get_all_project",resultAllProjectList,"POST").send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/ca/get_all_project",resultAllProjectList,"POST");
            http.resultFunArr.addItem(fun);
            http.send();

        }

    }
    public static function resultAllProjectList(result:Object,e:ResultEvent):void{
        if(result.success==true){
            allProjectList.removeAll();
            allProjectList.addAll(new ArrayCollection(result.result as Array));

        }
    }


    [Bindable]
    public static var memberList:ArrayCollection=new ArrayCollection();

    public static function getPersonById(id:*):Object{
        for each(var item:Object in memberList){
            if(item.id == id){
                return item;
            }
        }
        return new Object();
    }

    [Bindable]
    public static var org:Object = null;

    public static function currentOrgRefresh(fun:Function=null):void{

        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/riliusers/getCurrentOrg",resultCurrentOrg,"POST").send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/riliusers/getCurrentOrg",resultCurrentOrg,"POST");
            http.resultFunArr.addItem(fun);
            http.send();

        }

    }
    public static function resultCurrentOrg(result:Object,e:ResultEvent):void{
        if(result.success==true){
            org = result.result.org
            memberList.removeAll();
            memberList.addAll(new ArrayCollection(result.result.members as Array));

        }
    }

    [Bindable]
    public static var pluginList:ArrayCollection=new ArrayCollection();

    public static function pluginRefresh(fun:*=null,e:*=null):void{

        if(!(fun is Function)){
            HttpServiceUtil.getCHTTPServiceAndResult("/PluginNameList",resultAllPlugin,"POST").send();
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/PluginNameList",resultAllPlugin,"POST");
            http.resultFunArr.addItem(fun);
            http.send();

        }

    }
    public static function resultAllPlugin(result:Object,e:ResultEvent):void{
        if(result.success==true){
            pluginList.removeAll();
            if(result.result){
                pluginList.addAll(new ArrayCollection(result.result as Array));
            }

        }
    }
//    [Bindable]
//    public static var taskUnList:ArrayCollection=new ArrayCollection();
//
//    public static function taskUnRefresh(fun:*=null,e:*=null):void{
//        var obj:Object=new Object();
//        obj["status"]=false;
//        if(!(fun is Function)){
//            HttpServiceUtil.getCHTTPServiceAndResult("/ca/getTaskByStatus",resultAllUnTask,"POST").send(obj);
//        }else{
//            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/ca/getTaskByStatus",resultAllUnTask,"POST");
//            http.resultFunArr.addItem(fun);
//            http.send(obj);
//
//        }
//
//    }
//    public static function resultAllUnTask(result:Object,e:ResultEvent):void{
//        if(result.success==true){
//            taskUnList.removeAll();
//            if(result.result){
//                taskUnList.addAll(new ArrayCollection(result.result as Array));
//            }
//
//        }
//    }
//    [Bindable]
//    public static var taskList:ArrayCollection=new ArrayCollection();
//
//    public static function getTask(id:String):Object{
//        for each(var item:Object in taskUnList){
//            if(item.id==id){
//                return item;
//            }
//        }
//        for each(item in taskList){
//            if(item.id==id){
//                return item;
//            }
//        }
//        return null;
//    }
//
//    public static function taskRefresh(fun:*=null,e:*=null):void{
//        var obj:Object=new Object();
//        obj["status"]=true;
//        if(!(fun is Function)){
//            HttpServiceUtil.getCHTTPServiceAndResult("/ca/getTaskByStatus",resultAllTask,"POST").send(obj);
//        }else{
//            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/ca/getTaskByStatus",resultAllTask,"POST");
//            http.resultFunArr.addItem(fun);
//            http.send(obj);
//
//        }
//
//    }
//    public static function resultAllTask(result:Object,e:ResultEvent):void{
//        if(result.success==true){
//            taskList.removeAll();
//            if(result.result){
//                taskList.addAll(new ArrayCollection(result.result as Array));
//            }
//
//        }
//    }

    public static var scheduleMap:Object = new Object();



    public static function getSchedule(id:String):Object{
        if(ToolUtil.scheduleMap.hasOwnProperty("schedulemap")&&ToolUtil.scheduleMap.schedulemap.hasOwnProperty(id)){
            return ToolUtil.scheduleMap.schedulemap[id];
        }
        return null;
    }



    public static function getScheduleByDate(start:String,end:String,fun:Function=null):void{
        var obj:Object = new Object();
        obj["startdate"] = start;
        obj["enddate"] = end;

        if(fun==null){
            HttpServiceUtil.getCHTTPServiceAndResult("/ca/getScheduleByDate",queryResult,"POST").send(obj);
        }else{
            var http:CHTTPService=HttpServiceUtil.getCHTTPServiceAndResult("/ca/getScheduleByDate",queryResult,"POST");
            http.resultFunArr.addItem(fun);
            http.send(obj);

        }

    }

    public static function queryResult(result:Object,e:ResultEvent):void{
        if(result.success){
            if(result.result){
                scheduleMap=result.result;

                if(ToolUtil.scheduleMap.hasOwnProperty("schedulemap")){
                    for(var sid:String in scheduleMap.schedulemap){
//                        ScheduleUtil.updateSchedulePanel(sid);
                    }
                }
            }

            FlexGlobals.topLevelApplication.dispatchEvent(new ChangeScheduleEvent(true));
        }

    }



}
}