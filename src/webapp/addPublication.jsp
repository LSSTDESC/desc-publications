<%-- 
    Document   : addPublication
    Created on : Aug 3, 2017, 1:38:15 PM
    Author     : chee
--%>

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add Publication Page</title>
    </head>
    <body>
        <h1>Add publication to project ${param.projid} and working group ${param.swgid} on experiment ${param.experiment}</h1>
        <c:forEach var="x" items="${param}">
            <c:out value="${x.key} = ${x.value}"/><br/>
        </c:forEach>
       
        <sql:update dataSource="jdbc/config-dev">
            insert into descpub_publication (id, title, state, added, builder_eligible, keypub, project_id) values(DESCPUB_PUB_SEQ.nextval,?,?,sysdate,?,?,?)
            <sql:param value="${param.title}"/>
            <sql:param value="in preparation"/>
            <sql:param value="U"/>
            <sql:param value="U"/>
            <sql:param value="${param.projid}"/>
        </sql:update>

        <c:redirect url="${param.redirectTo}?projid=${param.projid}&swgid=${param.swgid}"/>  

    </body>
</html>
