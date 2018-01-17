package org.lsstdesc.pubs;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

/**
 *
 * @author tonyj
 */
public class MailSender implements Runnable {

    private static final Logger LOG = Logger.getLogger(MailSender.class.getName());
    private final ServletContext servletContext;
    Properties mailProperties = new Properties();

    public MailSender(ServletContext servletContext) {
        this.servletContext = servletContext;
        mailProperties.put("mail.smtp.host",getInitParameter("mail.smtp.host", "smtpserv.slac.stanford.edu"));
    }
    
    private String getInitParameter(String name, String defaultValue) {
       String result = servletContext.getInitParameter(name);
       return result == null ? defaultValue : result;
    }

    @Override
    public void run() {
        try (Connection conn = ConnectionManager.getConnection(servletContext, getInitParameter("mail.database","jdbc/config-prod"))) {
            DBUtilities db = new DBUtilities(conn);
            int count = db.getMailCount();
            LOG.log(Level.INFO, "{0} mail messages to send", count);
            if (count > 0) {
                Session session = Session.getDefaultInstance(mailProperties);
                for (;;) {
                    Message message = new MimeMessage(session);
                    message.setFrom(new InternetAddress(getInitParameter("mail.from", "noreply@lsstdesc.org"),
                            getInitParameter("mail.from.name","DESC Publication System")));
                    message.setReplyTo(new Address[]{new InternetAddress(getInitParameter("mail.replyTo","chee@slac.stanford.edu"))});
                    int messageId = db.getNextMessage(message);
                    if (messageId < 0) {
                        break;
                    }
                    Transport.send(message);
//                    db.purgeMessage(messageId);
                    LOG.log(Level.INFO, "Sent message {0}", messageId);

                }
            }
        } catch (NamingException | SQLException | MessagingException | UnsupportedEncodingException ex) {
            LOG.log(Level.SEVERE, "Error sending e-mail", ex);
        } 
    }
}
