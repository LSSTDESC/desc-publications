<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Authorship Display</title>
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <script src="js/moveUpDown.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        <h1>Authorship</h1>
        <sql:query var="auth">
            select v.first_name, v.last_name, v.memidnum, v.email from profile_user v join profile_ug ug on v.memidnum=ug.memidnum and
            v.experiment=ug.experiment where ug.group_id = ? and v.experiment = ?  order by v.last_name
            <sql:param value="lsst-desc-members"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
               
        <c:choose>
            <c:when test="${empty param.submit}">
            <form name="authlist" action="authorshipDisplay.jsp" method="post">
                <select name="select2" id="select2" size="30" multiple >
                    <c:forEach var="author" items="${auth.rows}" >
                       <option value="${author.memidnum}">${author.last_name}, ${author.first_name}</option>
                    </c:forEach>
                </select> 
                <p></p>
                <input type="button" value="Up"/>
                <input type="button" value="Down"/>
                <input type="submit" value="submit" name="submit"/>
            </form> 
            </c:when>
            <c:when test="${!empty param.submit}">
                <c:forEach var="current" items="${param}">
                    <c:out value="Param: ${current.key}"/><br/>
                    <c:forEach var="subcurr" items="${paramValues[current.key]}">
                        <c:out value="paramVal: ${subcurr}"/><br/>
                    </c:forEach>
                </c:forEach>
            </c:when>
       </c:choose>
        
    </body>
</html>
