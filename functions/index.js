/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();

exports.sendFCMNotification = functions.firestore
    .document('fcm_messages/{messageId}')
    .onCreate(async (snap, context) => {
        const message = snap.data();
        
        // Vérifier si le message a déjà été traité
        if (message.status === 'sent') {
            return null;
        }

        const payload = {
            notification: {
                title: message.notification.title,
                body: message.notification.body,
                sound: 'default',
                badge: '1'
            },
            data: message.data || {},
            token: message.token,
            android: {
                priority: 'high',
                notification: {
                    channelId: 'high_importance_channel',
                    sound: 'default',
                    priority: 'high',
                    defaultSound: true,
                    defaultVibrateTimings: true,
                    defaultLightSettings: true
                }
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1
                    }
                }
            }
        };

        try {
            // Envoyer la notification
            const response = await admin.messaging().send(payload);
            console.log('Successfully sent notification:', response);

            // Mettre à jour le statut du message
            await snap.ref.update({
                status: 'sent',
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                fcmResponse: response
            });

            return null;
        } catch (error) {
            console.error('Error sending FCM notification:', error);
            
            // Mettre à jour le statut en cas d'erreur
            await snap.ref.update({
                status: 'error',
                error: error.message,
                errorAt: admin.firestore.FieldValue.serverTimestamp()
            });

            throw error;
        }
    });
