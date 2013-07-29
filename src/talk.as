package
{
	import com.talk.assets.TalkWindowAsset;
	import com.talkClient.TalkClient;
	import com.talkClient.TalkClientCmd;
	import com.talkClient.TalkClientEvent;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.KeyboardType;
	import flash.utils.ByteArray;
	
	public class talk extends Sprite
	{
		public static var TALK_RECONNECT_INTERVAL:int	= 5000; // 单位毫秒
		
		private var _asset:Sprite;
		
		private var _hostText:TextField;
		private var _portText:TextField;
		private var _idText:TextField;
		
		private var _sendBtn:SimpleButton;
		private var _connectBtn:SimpleButton;
		
		private var _sendText:TextField;
		private var _recvText:TextField;
		
		private var _talkClient:TalkClient;
		
		public function talk()
		{
			_asset	= new com.talk.assets.TalkWindowAsset();
			
			_hostText	= _asset.getChildByName("hostText") as TextField;
			_hostText.text	= "192.168.1.34";
			
			_portText	= _asset.getChildByName("portText") as TextField;
			_portText.text	= "55555";
			
			_idText		= _asset.getChildByName("idText") as TextField;
			_idText.text	= "11111";
			
			_connectBtn	= _asset.getChildByName("connectBtn") as SimpleButton;
			_connectBtn.addEventListener(MouseEvent.CLICK, onConnectClick);
			_sendBtn	= _asset.getChildByName("sendBtn") as SimpleButton;
			_sendBtn.addEventListener(MouseEvent.CLICK, onSendClick);
			
			_sendText	= _asset.getChildByName("sendText") as TextField;
			_sendText.text	= "";
			
			_recvText	= _asset.getChildByName("recvText") as TextField;
			_recvText.wordWrap	= true;
			_recvText.multiline	= true;
			_recvText.text	= "";
			
			_asset.x += _asset.width / 2 + 10;
			_asset.y += _asset.height / 2 + 10;
			
			addChild(_asset);
		}
		
		protected function onSendClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var cmdData:Array	= _sendText.text.split("|");
			switch(cmdData[0]){
				case "broadcast":
					_talkClient.broadcast(cmdData[1]);
					break;
				case "multicast":
					_talkClient.multicast(cmdData[1]);
					break;
				case "enterRoom":
					_talkClient.enterRoom(parseInt(cmdData[1]));
					break;
				case "quitRoom":
					_talkClient.quitRoom();
					break;
				case "logout":
					_talkClient.logout();
					break;
				case "getOnlineUser":
					_talkClient.getOnlineUser();
					break;
				case "getRoomUser":
					_talkClient.getRoomUser(parseInt(cmdData[1]));
					break;
				default:
					output("unknown cmd "+cmdData[0]);
			}
			
			_sendText.text	= "";
		}
		
		protected function output(msg:String):void
		{
			trace(msg);
			_recvText.text	= msg + "\n" + _recvText.text;
		}
		
		protected function onConnectClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var host:String	= _hostText.text;
			var port:int	= parseInt(_portText.text);
			_talkClient	= new TalkClient(host, port, TALK_RECONNECT_INTERVAL);
			_talkClient.addEventListener(TalkClientEvent.CONNECT, onConnect);
			_talkClient.addEventListener(TalkClientEvent.CMD, onCmd);
			
			_talkClient.connect();
			
			output("connecting "+host+":"+port.toString()+"...");
		}
		
		protected function onCmd(event:TalkClientEvent):void
		{
			// TODO Auto-generated method stub
			var cmd:TalkClientCmd	= event.cmd;
			var i:int;
			
			output("recv cmd,type="+cmd.type+",ret="+cmd.ret);
			if(cmd.ret != TalkClient.RET_SUCC){
				return ;
			}
			
			switch(cmd.type){
				case TalkClientCmd.TYPE_LOGIN:
					output("login succ");
					break;
				case TalkClientCmd.TYPE_LOGOUT:
					output("logout succ");
					break;
				case TalkClientCmd.TYPE_HEARTBEAT:
					output("heartbeat succ");
					break;
				case TalkClientCmd.TYPE_BROADCAST:
					output("recv broadcast msg:"+cmd.msg);
					break;
				case TalkClientCmd.TYPE_MULTICAST:
					output("recv multicast msg:"+cmd.msg);
					break;
				case TalkClientCmd.TYPE_ENTER_ROOM:
					output("enter room succ");
					break;
				case TalkClientCmd.TYPE_QUIT_ROOM:
					output("quit room succ");
					break;
				case TalkClientCmd.TYPE_GET_ROOM_USER:
					output("get room user succ");
					for(i = 0; i < cmd.userList.length; ++i){
						output(cmd.userList[i].id + "--" + cmd.userList[i].name + "--" + cmd.userList[i].icon);
					}
					break;
				case TalkClientCmd.TYPE_GET_ONLINE_USER:
					output("get room user succ");
					for(i = 0; i < cmd.userList.length; ++i){
						output(cmd.userList[i].id + "--" + cmd.userList[i].name + "--" + cmd.userList[i].icon);
					}
					break;
				default:
					output("unkonw cmd type!!!!!type="+cmd.type);
			}
		}
		
		protected function onConnect(event:Event):void
		{
			// TODO Auto-generated method stub
			output("connected succ");
			var tgw:ByteArray = new ByteArray();
			tgw.writeMultiByte("tgw_l7_forward\r\nHost: app100645243.qzone.qzoneapp.com:8008\r\n\r\n","GBK");
			_talkClient.sendRaw(tgw);
			_talkClient.login(_idText.text, "talkClient", "icon url");
		}
	}
}
