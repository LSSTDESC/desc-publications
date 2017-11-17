package org.lsstdesc.pubs;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
                    throw new SQLException("Invalid file paperId="+paperId+" version="+version);
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
                    throw new SQLException("Invalid file paperId="+paperId);
                }
            }
        }        
    }
}
