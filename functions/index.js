const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// FCM 알림 전송 함수
exports.sendFCMNotification = onDocumentCreated(
    {
      region: "asia-northeast3", // 서울 리전 명시
      document: "fcm_requests/{requestId}",
    },
    async (event) => {
      const data = event.data.data();
      const token = data.token;

      const message = {
        notification: {
          title: data.title,
          body: data.body,
        },
        token: token,
      };

      try {
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        await event.data.ref.delete();
      } catch (error) {
        console.log("Error sending message:", error);
      }
    },
);
