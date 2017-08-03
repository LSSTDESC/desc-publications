<%-- 
    Document   : requestAuthorship
    Created on : Aug 1, 2017, 3:24:31 PM
    Author     : chee
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib uri="http://jakarta.apache.org/taglibs/mailer2" prefix="mt" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <title>Request Authorship Form</title>
    </head>
    
    <body>
        
        <c:set var="theFrom" value="chee@slac.stanford.edu"/>
        <c:set var="theTo" value="chee@slac.stanford.edu"/>
        
        <c:choose>
            <c:when test="${formsubmitted != 'Y'}">
                <h3>Request Authorship For Publication ${pubname}</h3>
                <p/>
                Reason:
                <p/>
                <form action="requestAuthorship.jsp">
                    <textarea rows="20" cols="80" required></textarea><p/>
                    <input type="hidden" name="formsubmitted" value="Y"/>
                    <input type="submit" value="submit" name="submit"/>
                </form> 
            </c:when>
            <c:when test="${formsubmitted == 'Y'}">
                <mt:mail subject="DESC Authorship Request" from="${theFrom}" to="${theTo}">
                    request authorship form submitted
                </mt:mail>
            </c:when>    
        </c:choose>
    </body>
</html>
