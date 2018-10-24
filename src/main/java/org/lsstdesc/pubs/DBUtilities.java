package org.lsstdesc.pubs;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;
import javax.servlet.ServletException;
import org.apache.commons.fileupload.FileItem;
import org.apache.tika.Tika;

/**
 *
 * @author tonyj
 */
public class DBUtilities {

    private final Connection conn;

    DBUtilities(Connection conn) {
        this.conn = conn;
    }

    void insertPaperVersion(int paperid, int version, String remarks, String origname, String location, String mimetype) throws SQLException {

        String insStr = "insert into descpub_publication_versions (paperid, tstamp, version, remarks, origname, location, mimetype) values (?, sysdate, ?, ?, ?, ?, ?)";
        try (PreparedStatement insertStatement = conn.prepareStatement(insStr)) {
            insertStatement.setInt(1, paperid);
            insertStatement.setInt(2, version);
            insertStatement.setString(3, remarks);
            insertStatement.setString(4, origname);
            insertStatement.setString(5, location);
            insertStatement.setString(6, mimetype);
            insertStatement.execute();
        }

    }

    int getMaxExistingVersion(int paperid) throws SQLException {
        String maxVer = "select max(version) version from DESCPUB_PUBLICATION_VERSIONS where paperid = ?";
        try (PreparedStatement maxVersionStatement = conn.prepareStatement(maxVer)) {
            maxVersionStatement.setInt(1, paperid);
            try (ResultSet rs = maxVersionStatement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    return 0;
                }
            }
        }

    }

    String getFiletype (FileItem item) throws IOException, ServletException {
//      make sure we split on the last dot, in case the filename contains more than one of them
        String[] parts = item.getName().split("\\.(?=[^.]*$)");
        if (parts.length > 0){
           String filetype = parts[1];
           return filetype;
        } else {
            return null;
        }
    }
    
    String allowedMimetype(FileItem item) throws IOException, ServletException {
//        Check if mimetype is one of the allowed types        
          String allowedtype = null;
           
//          ArrayList<String> allowedList = new ArrayList<String>();
//          allowedList.add("application/vnd.apple.keynote");
//          allowedList.add("application/vnd.ms-powerpoint");
//          allowedList.add("application/vnd.openxmlformats-officedocument.presentationml.presentation");
//          allowedList.add("application/x-tex");
//          allowedList.add("image/png");
//          allowedList.add("image/jpeg");
//          allowedList.add("image/gif");
//          allowedList.add("application/vnd.ms-excel");
//          allowedList.add("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
//          allowedList.add("application/msword");
//          allowedList.add("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
//          allowedList.add("application/pdf");
//          allowedList.add("application/vnd.oasis.opendocument.text");
//          allowedList.add("application/x-dvi");
          
          Tika tika = new Tika();        
 
              if ("application/vnd.openxmlformats-officedocument.presentationml.presentation".equalsIgnoreCase(tika.detect(item.getName()))){
                   allowedtype = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
              } else if ("image/tiff".equalsIgnoreCase(tika.detect(item.getName()))) {
                   allowedtype = "image/tiff";
              } else if ("application/vnd.apple.keynote".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype = "application/vnd.apple.keynote";
              } else if ("application/vnd.ms-powerpoint".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/vnd.ms-powerpoint";
              } else if ("application/x-tex".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/x-tex";
              } else if ("image/png".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="image/png";
              } else if ("image/jpeg".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="image/jpeg";
              } else if ("image/gif".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="image/gif";
              } else if ("application/vnd.ms-excel".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype = "application/vnd.ms-excel";
              } else if ("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
              } else if ("application/msword".equalsIgnoreCase(item.getName())) {
                  allowedtype ="application/msword";
              } else if ("application/vnd.openxmlformats-officedocument.wordprocessingml.document".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/vnd.openxmlformats-officedocument.wordprocessingml.document";
              } else if ("application/pdf".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/pdf";
              } else if ("application/vnd.oasis.opendocument.text".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype ="application/vnd.oasis.opendocument.text";
              } else if ("application/x-dvi".equalsIgnoreCase(tika.detect(item.getName()))) {
                  allowedtype = "application/x-dvi";
              } else {
                  throw new ServletException(item.getName() + " is not a recognized mimetype");
              }

          return allowedtype;
    }
    
    String getMimetype(int paperid, int version) throws SQLException {
//      When uploading, get the mimetype for the browser. Every uploaded paper should have a mimetype associated with it
//        String defaultMimeType = "application/pdf";
//      No default mimetype. File must be one of the allowed mimetypes.        
        String sql;
        if (version == 0){
            sql = "select mimetype from DESCPUB_PUBLICATION_VERSIONS where version in (select max(version) from DESCPUB_PUBLICATION_VERSIONS where paperid = ?) and paperid=? ";
        } else {
            sql = "select mimetype from DESCPUB_PUBLICATION_VERSIONS where version=? and paperid=?";
        }
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (version == 0){
                stmt.setInt(1, paperid);
                stmt.setInt(2, paperid);
            }
            else {
                stmt.setInt(1, version);
                stmt.setInt(2, paperid);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String mtype = rs.getString(1);
                    return mtype;
//                    return (mtype != null ? mtype : defaultMimeType);
                } else {
                    throw new SQLException("Could not get mimetype for paperid=" + paperid + " version=" + version);
                }
            }
        }
    }

    void commit() throws SQLException {
        conn.commit();
    }

    File getFile(int paperid, int version) throws SQLException {
        // url request may or may not include a version number. If no version number is specified the default is to return the most recent file.
        String sql;
        if (version == 0){
            sql = "select location from DESCPUB_PUBLICATION_VERSIONS where version in (select max(version) from DESCPUB_PUBLICATION_VERSIONS where paperid = ?) and paperid=? ";
        } else {
            sql = "select location from DESCPUB_PUBLICATION_VERSIONS where version=? and paperid=?";
        }
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (version == 0){
                stmt.setInt(1, paperid);
                stmt.setInt(2, paperid);
            }
            else {
                stmt.setInt(1, version);
                stmt.setInt(2, paperid);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new File(rs.getString(1));
                } else {
                    throw new SQLException("Invalid file paperid=" + paperid + " version=" + version);
                }
            }
        }
    }

    int getProjectForPaper(int paperid) throws SQLException {
        String sql = "select project_id from descpub_publication where paperid=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, paperid);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Invalid file paperid=" + paperid);
                }
            }
        }
    }

    int getMailCount() throws SQLException {
        String sql = "select count(*) from descpub_mailbody";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Unexpected error executing sql " + sql);
                }
            }
        }

    }

    int getNextMessage(Message message) throws SQLException, MessagingException {
        int msgId;
        String sql = "select msgid,subject,body,askdate from descpub_mailbody where rownum<=1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    msgId = rs.getInt(1);
                    message.setSubject(rs.getString(2));
                    Date date = rs.getDate(4);
                    if (date != null) message.setSentDate(date);
                    BodyPart messageBodyPart = new MimeBodyPart();
                    messageBodyPart.setText(rs.getString(3));
                    Multipart multipart = new MimeMultipart();
                    multipart.addBodyPart(messageBodyPart);
                    message.setContent(multipart);
                } else {
                    return -1;
                }
            }
        }
        addMailRecipients(msgId,message);
        return msgId;
    }
   
    void purgeMessage(int messageId) throws SQLException {
        String sql = "delete from descpub_mailbody where msgid=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, messageId);
            stmt.execute();
        }
    }

    private void addMailRecipients(int messageId, Message message) throws SQLException, MessagingException {
        String sql = "select groupname_or_emailaddr from descpub_mail_recipient where msgid=?";
        String sqlgrp = "select v.email as email from profile_user v join profile_ug u on v.memidnum=u.memidnum and v.experiment=u.experiment join descpub_mail_recipient r on r.groupname_or_emailaddr=u.group_id where u.experiment=? and r.msgid=?";
        String exp = "LSST-DESC";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, messageId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String groupOrEmail = rs.getString(1);
                    if (groupOrEmail.contains("@")) {
                        message.addRecipient(Message.RecipientType.TO, new InternetAddress(groupOrEmail));
                    } else if (! groupOrEmail.contains("@")) {
                        // TOOD: Deal with groups
                        try(PreparedStatement stmt2 = conn.prepareStatement(sqlgrp)){
                            stmt2.setString(1,exp);
                            stmt2.setInt(2, messageId);
                            ResultSet addrs = stmt2.executeQuery();
                            while(addrs.next()){
                                message.addRecipient(Message.RecipientType.TO,new InternetAddress(addrs.getString(1)));
                            }
                        }
                    }
                } 
            }
        }
    }
    
}
