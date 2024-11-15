const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// FCM 알림 전송 함수
exports.sendFCMNotification = onDocumentCreated(
    {
      document: "notifications/{notificationId}",
      region: "asia-northeast3"
    },
    async (event) => {
      const notification = event.data.data();
      
      try {
        // 사용자의 FCM 토큰 가져오기
        const userDoc = await admin.firestore()
          .collection("users")
          .doc(notification.userId)
          .get();
        
        const fcmToken = userDoc.data()?.fcmToken;
        
        if (!fcmToken) {
          console.log("No FCM token found for user:", notification.userId);
          return null;
        }

        // 채팅 메시지와 일반 알림에 따라 다른 메시지 구성
        const message = {
          token: fcmToken,
          notification: {
            title: notification.title,
            body: notification.message,
          },
          data: {
            type: notification.type,
          },
          android: {
            priority: "high",
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
              },
            },
          },
        };

        // notification type에 따라 추가 데이터 설정
        if (notification.type === "chat_message") {
          message.data.chatId = notification.chatId || "";
        } else {
          message.data.reservationId = notification.reservationId || "";
        }

        // FCM 메시지 전송
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        
      } catch (error) {
        console.log("Error sending notification:", error);
      }
    }
);
