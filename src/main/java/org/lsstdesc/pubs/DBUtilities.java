package org.lsstdesc.pubs;

import java.io.File;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

/**
 *
 * @author tonyj
 */
public class DBUtilities {

    private final Connection conn;

    DBUtilities(Connection conn) {
        this.conn = conn;
    }

    void insertPaperVersion(int paperId, int version, String remarks, String origname, String location) throws SQLException {

        String insStr = "insert into descpub_publication_versions (paperid, tstamp, version, remarks, origname, location) values (?, sysdate, ?, ?, ?, ?)";
        try (PreparedStatement insertStatement = conn.prepareStatement(insStr)) {
            insertStatement.setInt(1, paperId);
            insertStatement.setInt(2, version);
            insertStatement.setString(3, remarks);
            insertStatement.setString(4, origname);
            insertStatement.setString(5, location);
            insertStatement.execute();
        }

    }

    int getMaxExistingVersion(int paperId) throws SQLException {
        String maxVer = "select max(version) version from DESCPUB_PUBLICATION_VERSIONS where paperid = ?";
        try (PreparedStatement maxVersionStatement = conn.prepareStatement(maxVer)) {
            maxVersionStatement.setInt(1, paperId);
            try (ResultSet rs = maxVersionStatement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    return 0;
                }
            }
        }

    }

    void commit() throws SQLException {
        conn.commit();
    }

    File getFile(int paperId, int version) throws SQLException {
        String sql = "select location from DESCPUB_PUBLICATION_VERSIONS where version=? and paperid=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, version);
            stmt.setInt(2, paperId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new File(rs.getString(1));
                } else {
                    throw new SQLException("Invalid file paperId=" + paperId + " version=" + version);
                }
            }
        }
    }

    int getProjectForPaper(int paperId) throws SQLException {
        String sql = "select project_id from descpub_publication where paperid=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, paperId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Invalid file paperId=" + paperId);
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
                                String emailAddr = addrs.getString(1);
                                message.addRecipient(Message.RecipientType.TO,new InternetAddress(addrs.getNString(emailAddr)));
                            }
                        }
                    }
                } 
            }
        }
    }

}
