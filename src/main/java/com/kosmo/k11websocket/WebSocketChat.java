package com.kosmo.k11websocket;

import java.util.ArrayList;
import java.util.List;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.RemoteEndpoint.Basic;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;

/**
 * @EchoServer.do : 웹소켓 서버의 요청명을 지정한다. 주소는
 *                ws://localhost:8081/k11websocket/EchoServer.do 이와같이 설정한다.
 *                http대신 웹소켓이라는 의미로 ws를 사용한다.
 */
@Controller
@ServerEndpoint("/EchoServer.do")
public class WebSocketChat {

	/**
	 * 해당 List컬렉션은 클라이언트가 접속할때마다 세션ID를 저장하는 용도로 사용한다.
	 * 
	 * 접속한 웹브라우저가 웹소켓을 지원해야 하며, 웹브라우절르 닫으면 OnClose가 호출된다.
	 */
	private static final List<Session> sessionList = new ArrayList<Session>();
	private static final Logger logger = LoggerFactory.getLogger(WebSocketChat.class);

	// 생성자를 통해 언제 생성되는지 알 수 잇음
	public WebSocketChat() {
		System.out.println("웹소켓(서버) 객체 생성");
	}

	// 클라이언트가 접속했을때 호출됨
	@OnOpen
	public void onOpen(Session session) {
		logger.info("Open session id:" + session.getId());

		try {
			final Basic basic = session.getBasicRemote();
			basic.sendText("대화방에 연결 되었습니다.");
		} 
		catch (Exception e) {
			System.out.println(e.getMessage());
		}
		/*
		 * 클라이언트가 접속하면 List컬렉션에 추가한다.
		 */
		sessionList.add(session);
	}

	// 서버가 모든 클라이언트에게 메세지를 전송(Echo)해줌
	private void sendAllSessionToMessage(Session self, String message) {
		try {
			//List컬렉션에 저장된 클라이언트만큼 반복
			for (Session session : sessionList) {
				//메세지를 보낸 자신을 제외한 나머지에게 메세지 보냄
				if (!self.getId().equals(session.getId())) {
					//sendText() 메소드를 통해 메세지 전송
					session.getBasicRemote().sendText(message);
				}
			}
		} 
		catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

	// 클라이언트가 보낸 메세지가 도착했을때 호출
	@OnMessage
	public void onMessage(String message, Session session) {
		logger.info("Message Form: " + message);
		try {
			final Basic basic = session.getBasicRemote();
		} 
		catch (Exception e) {
			System.out.println(e.getMessage());
		}
		//클라이언트 전체에게 메세지 전송
		sendAllSessionToMessage(session, message);
	}

	// 채팅중 오류가 발생했을대 호출
	@OnError
	public void onError(Throwable e, Session session) {
		e.printStackTrace();
	}

	// 클라이언트가 접속을 종료했을때
	@OnClose
	public void onClose(Session session) {
		logger.info("Session " + session.getId() + " has ended");
		//접속 종료시에는 List컬렉션에서 삭제함
		sessionList.remove(session);
	}

}