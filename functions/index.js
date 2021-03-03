'use strict';
const functions = require("firebase-functions");
const admin = require('firebase-admin');
const { app } = require("firebase-admin");

// Setup twilio for sms
const twilio = require('twilio');
const config = require('./config.json');

const client = twilio(config.TIWLIO_ACCOUNT_SID, config.TWILIO_AUTH_TOKEN);

// Setup nodemailer
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});

let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
    user: 'expiryreminderapp@gmail.com',
    pass: config.GMAIL_AUTH_KEY  //you your password
    }
    });

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});
const database = admin.firestore();

exports.sendNotification = functions.pubsub.schedule('* * * * *').onRun(async (context)=>{
    const twilioNumber = "+15153165896";
    var promises = [];
        const users = await database.collection('users').get();
        users.forEach(async userDoc =>{
            var products = await database.collection('users').doc(userDoc.id).collection('personalProducts').get();
            products.forEach(async productDoc => {
                var alerts = await database.collection('users').doc(userDoc.id).collection('personalProducts').doc(productDoc.id).collection('alert').get();
               
                    alerts.forEach(async alertDoc => {
                        console.log(alertDoc.data().alertDatetime);
                        console.log(admin.firestore.Timestamp.now());
                        console.log( alertDoc.data().isAlert==false);
                        if(alertDoc.data().alertDatetime<=admin.firestore.Timestamp.now()&& alertDoc.data().isAlert==false){
                            var alertType = alertDoc.data().alertType;
                            alertType.forEach(async alertIndex => {
                                console.log(alertIndex);
                                var token = userDoc.data().fcmToken;
                                var productName = productDoc.data().productName;
                                var expiryDate = productDoc.data().expiryDate;
                                var userName = userDoc.data().name;
                                if(alertIndex==0){
                                    //  Send push notifications                                    
                                    let title = `${productName} is expiring soon`;
                                    let body = `${productName} is expiring on ${expiryDate}.`;
                            
                                    const payload = {
                                        notification: { title: title, body: body },
                                    }
                        
                                    promises.push(admin.messaging().sendToDevice(token, payload));
                                    await database.collection('users').doc(userDoc.id).collection('personalProducts').doc(productDoc.id).collection('alert').doc(alertDoc.id).update({
                                        "isAlert":true,
                                    });
                                }     
                                if(alertIndex==1){
                                    // Send SMS reminder
                                    var phoneNumber = userDoc.data().phoneNumber;
                                    const formatPhoneNumber = phoneNumber.replace(" ","").replace("-","").replace(" ","");
                                   console.log(formatPhoneNumber);

                                    promises.push(client.messages.create({
                                        body:  `Dear ${userName}, ${productName} is expiring on ${expiryDate}. -By Expiry Reminder App`,
                                        to: formatPhoneNumber,  // Text to this number
                                        from: twilioNumber // From a valid Twilio number
                                    }));
                                    await database.collection('users').doc(userDoc.id).collection('personalProducts').doc(productDoc.id).collection('alert').doc(alertDoc.id).update({
                                        "isAlert":true,
                                    });
                                }    

                                if(alertIndex==2){
                                    var email = userDoc.data().email;
                                    // Send Email reminder
                                     const mailOptions = {
                                         from: 'expiryreminderapp@gmail.com',
                                         to: email,
                                         html: `Dear ${userName}, <br><br><p>Your product named<b> ${productName} </b>is expiring on<b> ${expiryDate}</b>.</p><br>Sincerely, <br> Expiry Reminder App`
                                     };

                                    promises.push( transporter.sendMail(mailOptions, (error, info)=>{
                                         if(error){
                                             return console.log(error.toString());
                                         }
                                         return console.log(info);

                                     }));
                                     await database.collection('users').doc(userDoc.id).collection('personalProducts').doc(productDoc.id).collection('alert').doc(alertDoc.id).update({
                                        "isAlert":true,
                                    });
                                }
                            });                           
                        }

                    });
                    
            });
        });   
   
    return Promise.all(promises);
});