<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Voting status</title>
    </head>
    <body>
        <sql:query var="parameters">
            select max_rank,test_mode,admin_name,admin_email,no_vote_column_name, no_vote_row_name,
                   to_char(start_time,'dd-mon-yyyy HH24:mi:ss TZR') as start_time,
                   to_char(end_time,'dd-mon-yyyy HH24:mi:ss TZR') as end_time from lsstdesc_voting_parameters
        </sql:query>
        <c:set var="max_rank" value="${parameters.rows[0]['max_rank']}"/>
        <c:set var="test_mode" value="${parameters.rows[0]['test_mode']=='Y'}"/>
        <c:set var="start_time" value="${parameters.rows[0]['start_time']}"/>
        <c:set var="end_time" value="${parameters.rows[0]['end_time']}"/>
        <c:set var="admin_name" value="${parameters.rows[0]['admin_name']}"/>        
        <c:set var="admin_email" value="${parameters.rows[0]['admin_email']}"/>
        <c:set var="no_vote_column_name" value="${parameters.rows[0]['no_vote_column_name']}"/>
        <c:set var="no_vote_row_name" value="${parameters.rows[0]['no_vote_row_name']}"/>
        <sql:query var="votes">
            select count(*) votes from lsstdesc_voting_record
        </sql:query>
        <c:set var="votes" value="${votes.rows[0]['votes']}"/>

        
        <table>
            <tr><td>Votes Allowed/Person:</td><td>${max_rank}</td></tr>
            <tr><td>Test Mode:</td><td>${test_mode}</td></tr>
            <tr><td>Vote Start Time:</td><td>${start_time}</td></tr>
            <tr><td>Vote End Time:</td><td>${end_time}</td></tr>
            <tr><td>Admin Name:</td><td>${admin_name}</td></tr>
            <tr><td>Admin E-mail:</td><td>${admin_email}</td></tr>
            <tr><td>No Vote Column Name:</td><td>${no_vote_column_name}</td></tr>
            <tr><td>No Vote Row Name:</td><td>${no_vote_row_name}</td></tr>
            <tr><td>Votes Cast:</td><td>${votes}</td></tr>
        </table>
        

    </body>
</html>
