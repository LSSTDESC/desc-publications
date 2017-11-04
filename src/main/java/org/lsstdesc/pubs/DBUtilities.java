package org.lsstdesc.pubs;

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

    void insertPaperVersion(int paperId, int version, String remarks, String origname, String uniqueName) throws SQLException {

        String insStr = "insert into descpub_publication_versions (paperid, tstamp, version, remarks, origname, uniquename) values (?, sysdate, ?, ?, ?, ?)";
        try (PreparedStatement insertStatement = conn.prepareStatement(insStr)) {
            insertStatement.setInt(1, paperId);
            insertStatement.setInt(2, version);
            insertStatement.setString(3, remarks);
            insertStatement.setString(4, origname);
            insertStatement.setString(5, uniqueName);
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
}
