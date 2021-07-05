<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<title>Insert title here</title>

</head>
<body>
<script type="text/javascript">
var messageWindow; //대화내용이 출력될 엘리먼트
var inputMessage; //입력상자
var chat_id;
var webSocket;
var logWindow; //대화창 아래에 로그를 출력할 부분
//해당 문서의 로드가 완료되었을때 무기명함수 실행됨
window.onload = function(){
	messageWindow = document.getElementById("messageWindow");
	messageWindow.scrollTop = messageWindow.scrollHeight;
	inputMessage = document.getElementById('inputMessage');
	chat_id = document.getElementById('chat_id').value;
	logWindow = document.getElementById('logWindow');
	
	//스크롤바를 항상 아래로 내려주는 역할을 담당
	messageWindow.scrollTop = messageWindow.scrollHeight;
	
	//웹소켓 서버에서 EndPoint로 선언된 값을 통해 웹소켓 객체 생성
	webSocket =
		new WebSocket('ws://localhost:8081/k11websocket/EchoServer.do');
	//만약 웹브라우저가 웹소켓을 지원하지 않는다면 객체를 생성할 수 없으므로 채팅을 사용할 수 없다.
	
	//클라이언트가 접속했을때
	webSocket.onopen = function(event){
		wsOpen(event);
	};
	
	//클라이언트가 메세지를 보냈을때
	webSocket.onmessage = function(event){
		wsMessage(event);
	};
	
	//클라이언트의 접속이 종료되었을때
	webSocket.onclose = function(event){
		wsClose(event);
	};
	
	//채팅중 에러가 발생했을때
	webSocket.onerror = function(event){
		wsError(event);
	};
}

function wsOpen(event){
	writeResponse("연결성공");
}

function wsMessage(event){
	/*
	메세지를 |(파이프) 으로 분리하여 앞부분은 보낸사람, 뒷부분은 메세지로
	각각 저장한다.
	*/
	var message = event.data.split("|");
	var sender = message[0];
	var content = message[1];
	var msg;
	
	writeResponse(event.data); //로그 남김
	
	if(content == ""){
		//전송된 내용이 없다면 아무것도 하지 않음
	}
	else{
		//내용에 / 가 있다면 귓속말 명령어로 판단
		if(content.match("/")){
			if (content.match("/" + chat_id)){
				//해당 아이디(닉네임)에게만 디스플레이 한다.
				var temp = content.replace(("/" + chat_id), "[귓속말]");
				//메세지에 UI(디자인)를 적용하는 부분
				msg = makeBalloon(sender, temp);
				//대화창에 내용 출력
				messageWindow.innerHTML += msg;
				//대화창의 스크롤바를 항상 아래로 내려준다.
				messageWindow.scrollTop = messageWindow.scrollHeight;
			}
		}
		else{
			//내용에 아무것도 없다면 일반적인 메세지로 판단
			msg = makeBalloon(sender, content);
			//대화창에 내용을 출력하고 스크롤바 처리
			messageWindow.innerHTML += msg;
			messageWindow.scrollTop = messageWindow.scrollHeight;
		}
	}
}

function wsClose(event){
	writeResponse("대화 종료");
}

function wsError(event){
	writeResponse("에러 발생");
	writeResponse(event.data);
}

//상대방이 보낸 메세지를 UI(디자인)를 적용하여 출력하기 위한 부분
function makeBalloon(id, cont){
	var msg = '';
	msg += '<div>'+id+':'+cont+'</div>';
	return msg;
}

//서버로 대화내용 전송하기
function sendMessage(){
	
	//웹소켓 서버로 대화내용을 전송한다. 전송시 파이프기호로 구분한다.
	webSocket.send(chat_id+'|'+inputMessage.value);
	
	//내가 보낸 내용을 대화창에 출력한다.
	//(서버로 메세지를 보내면 나를 제외한 다른 클라이언트에게만 메세지를 전송한다.)
	var msg = '';
	msg += '<div style="text-align:right;">'+inputMessage.value+'</div>';
	
	messageWindow.innerHTML += msg;
	inputMessage.value = "";
	//스크롤바 처리
	messageWindow.scrollTop = messageWindow.scrollHeight;
}

//대화내용을 입력한 후 Enter키를 통해 메세지를 전송할 수 있다.
function enterkey(){
	if(window.event.keyCode==13){
		sendMessage();
	}
}

//대화창 아래의 로그창에 채팅 내역을 남겨줌
function writeResponse(text){
	//기존에 있던 내용에 <br>을 추가하여 텍스트를 표시함
	logWindow.innerHTML += "<br/>"+text;
}
</script>

	<div class="container">
		<input type="hid den" id="chat_id" value="${param.chat_id }" /> <input
			type="hid den" id="chat_room" value="${param.chat_room }" />
		<table class="table table-bordered">
			<tr>
				<td>방명:</td>
				<td>${param.chat_room }</td>
			</tr>
			<tr>
				<td>닉네임:</td>
				<td>${param.chat_id }</td>
			</tr>
			<tr>
				<td>메시지:</td>
				<td><input type="text" id="inputMessage"
					class="form-control float-left mr-1" style="width: 75%"
					onkeyup="enterkey();" /> <input type="button" id="sendBtn"
					onclick="sendMessage();" value="전송" class="btn btn-info float-left" />
				</td> 
			</tr>
		</table>
		<div id="messageWindow" class="border border-primary"
			style="height: 300px; overflow: auto;">
			<div style="text-align: right;">내가쓴거</div>
			<div>상대가보낸거</div>
		</div>
		<div id="logWindow" class="border border-danger"
			style="height: 130px; overflow: auto;"></div>

	</div>

</body>
</html>