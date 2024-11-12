const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// FCM 알림 전송 함수
exports.sendFCMNotification = onDocumentCreated(
    {
      region: "asia-northeast3", // 서울 리전 명시
      document: "notifications/{notificationId}",
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

        // FCM 메시지 생성
        const message = {
          token: fcmToken,
          notification: {
            title: notification.title,
            body: notification.message,
          },
          data: {
            type: notification.type,
            reservationId: notification.reservationId || "",
          },
        };

        // FCM 메시지 전송
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        
      } catch (error) {
        console.log("Error sending notification:", error);
      }
    }
);
