<%-- 
    Document   : addDocument
    Created on : Aug 14, 2017, 2:15:25 PM
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
        <title>Add Document Page</title>
    </head>
    <body>
        
    <sql:query var="getwg" dataSource="jdbc/config-dev">
       select name from descpub_swg where id = ? 
       <sql:param value="${param.swgid}"/>
    </sql:query>
        <h1>Add document to project ${param.projid} and working group ${getwg.rows[0].name} on experiment ${param.experiment}</h1>
        <c:forEach var="x" items="${param}">
            <c:out value="${x.key} = ${x.value}"/><br/>
        </c:forEach>
         
            <%--
            <c:catch var="trapError">
            <sql:transaction dataSource="jdbc/config-dev">
                <sql:update >
                    insert into descpub_document (id, doctype, contribution_id) values(DESCPUB_DOC_SEQ.nextval,?,?)
                    <sql:param value="${param.doctype}"/>
                    <sql:param value="${param.memidnum}"/>
                </sql:update>

                <sql:query var="getdocid"  >
                    select DESCPUB_DOC_seq.currval as docid from dual
                </sql:query>

                <sql:update dataSource="jdbc/config-dev">
                    insert into descpub_documentreference (id, url, title, added, project_id) values(?,?,?,sysdate,?)
                    <sql:param value="${getdocid.rows[0].docid}"/>
                    <sql:param value="${param.url}"/>
                    <sql:param value="${param.title}"/>
                    <sql:param value="${param.project_id}"/>
                </sql:update>
            </sql:transaction>
            </c:catch>
            
        <c:redirect url="${param.redirectTo}?projid=${param.projid}&swgid=${param.swgid}"/>  
--%>
    </body>
</html>
