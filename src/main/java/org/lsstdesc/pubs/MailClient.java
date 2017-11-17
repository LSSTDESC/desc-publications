package org.lsstdesc.pubs;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
/**
 *
 * @author chee
 */
public class MailClient {
  
    public MailClient(){
    }
    public void sendMail(String mailServer, String msg, String toWhom, String exp) throws MessagingException, AddressException {
        String from = "chee@slac.stanford.edu";
//        String to = "chee@stanford.edu"; // when debugging send all email to tester's account
        String to = toWhom;
        String subject = exp + " Contact Information Check-in ";
        String messageBody = msg;
         
        Properties props = System.getProperties();
        props.put("mail.smtp.host",mailServer);
        
        // Get mail session
        Session session = Session.getDefaultInstance(props, null);
        
        // Get instance of message object and pass in the session
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject(subject);
        
         // Create a message part to represent the body text.  
        BodyPart messageBodyPart = new MimeBodyPart();
        messageBodyPart.setText(msg);

        //use a MimeMultipart as we need to handle the file attachments
        Multipart multipart = new MimeMultipart();

        //add the message body to the mime message
        multipart.addBodyPart(messageBodyPart);
     
        // Put all message parts in the message
        message.setContent(multipart);
        
        // Send the message
        Transport.send(message);
    }

    public static void main(String[] args) {
        System.out.println("*** Here in MAIN ***");
        try {
            MailClient client = new MailClient();
            String server="smtpunix.slac.stanford.edu";
            String from="chee@slac.stanford.edu";
            String to = "chee@slac.stanford.edu";
            String exp = "";
            String subject=exp + " Notice Update Test Email from Java ";
            
            System.out.println("client.sendMail call goes here. Leaving Main");
        } catch(Exception e) {
            e.printStackTrace(System.out);
        }
          
    }
}
