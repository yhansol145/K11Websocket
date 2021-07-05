<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<title>Insert title here</title>
<script type="text/javascript">
	var messageWindow;
	var inputMessage;
	var chat_id;
	var webSocket;
	var logWindow;
	window.onload = function() {
		messageWindow = document.getElementById("messageWindow");
		//messageWindow.scrollTop = messageWindow.scrollHeight;
		inputMessage = document.getElementById("inputMessage");
		chat_id = document.getElementById("chat_id").value;
		logWindow = document.getElementById("logWindow");

		webSocket = new WebSocket(
				'ws://localhost:8081/k11websocket/EchoServer.do');
		webSocket.onopen = function(event) {
			wsOpen(event);
		};
		webSocket.onmessage = function(event) {
			wsMessage(event);
		};
		webSocket.onclose = function(event) {
			wsClose(event);
		};
		webSocket.onerror = function(event) {
			wsError(event);
		};
	}

	function wsOpen(event) {
		writeResponse("연결성공");
	}

	function wsMessage(event) {
		var message = event.data.split("|");
		var sender = message[0]; //닉네임
		var content = "temp";
		content = message[1]; //메세지

		writeResponse(event.data);

		if (content == "") {
			//날라온 내용이 없으므로 아무것도 하지 않는다.
		} else {
			if (content.match("/")) {
				//귓속말 기능을 활용해서 특정 클라이언트 한명에게만 쪽지를 보낸다.
				if (content.match(("/" + chat_id))) {
					console.log("notify()");
					//노티함수 호출
					notify(content);
				}
			} else {
				//전체에게 보내고 싶을때 사용
			}
		}
	}

	function wsClose(event) {
		writeResponse("대화 종료");
	}

	function wsError(evnet) {
		writeResponse("에러 발생");
		writeResponse(event.data);
	}

	//웹소켓으로 메세지를 보냄
	function sendMessage() {
		//메세지를 귓속말을 보내듯이 조립한다. -> /닉네임 메세지 내용
		receive_id = $("#receive_id").val();
		inputMessage = '/' + receive_id + ' ' + $("#inputMessage").val();

		//메세지조립 및 전송
		var send_message = chat_id + '|' + inputMessage;
		console.log('send_message:' + send_message);
		webSocket.send(send_message);
	}
	function enterkey() {
		if (window.event.keyCode == 13) {
			sendMessage();
		}
	}
	function writeResponse(text) {
		//logWindow.innerHTML += "<br/>"+text;
		console.log(text);
	}
	function notify(notiMsg) {
		if (Notification.permission !== 'granted') {
			alert('notification is disabled');
		} else {
			var notification = new Notification(
					notiMsg,
					{
						icon : 'https://t4.ftcdn.net/jpg/00/78/87/93/500_F_78879336_2f2Ivwq2jN2EFMSJSi72OevDAQob2JJv.jpg',
						body : '쪽지가 왔습니다.',
					});
			//Noti에 핸들러를 사용한다.
			notification.onclick = function() {
				alert('링크를 이용해서 해당페이지로 이동할 수 있다.');
			};
		}
		//토스트로 표시
		$('.toast-body').html(notiMsg);
		$('.toast').toast({
			delay : 5000
		}).toast('show');
	}
</script>
</head>
<body>
	<div class="container">
		<table class="table table-bordered">
			<tr>
				<td>방명:</td>
				<td><input type="text" id="chat_room" class="form-control"
					value="${sessionScope.chat_room }" /></td>
			</tr>
			<tr>
				<td>닉네임:</td>
				<td><input type="text" id="chat_id" class="form-control"
					value="${sessionScope.chat_id }" /></td>
			</tr>
			<tr>
				<td>받는사람아이디:</td>
				<td><input type="text" id="receive_id" class="form-control"
					value="" placeholder="받는사람 아이디를 입력하세요" /></td>
			</tr>
			<tr>
				<td>쪽지내용:</td>
				<td><input type="text" id="inputMessage"
					class="form-control float-left mr-1" style="width: 70%"
					onkeyup="enterkey();" /> <input type="button" value="쪽지전송"
					onclick="sendMessage();" class="btn btn-info float-left" /></td>
			</tr>
		</table>

		<script>
    $(document).ready(function() {
    	//토스트 테스트
    	$('#myBtn').click(function(){
   		 $('.toast').toast({delay: 2000});
   		 $('.toast').toast('show');
   	 });
    });
    </script>
		<button type="button" class="btn btn-primary" id="myBtn">Show
			Toast</button>
		<div class="toast mt-3">
			<div class="toast-header">쪽지가 왔습니다.(5초후 닫힙니다.)</div>
			<div class="toast-body">쪽지내용</div>
		</div>
	</div>

</body>
</html>