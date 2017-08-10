<%-- 
    Document   : show_pub
    Created on : Jul 12, 2017, 6:49:15 PM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <h1>Publications</h1>
        
        <c:set var="pubid" value="${param.pubid}"/>
        <c:set var="projid" value="${param.projid}"/> 
        
        <sql:query var="swglist" dataSource="jdbc/config-dev">
            select sg.name, sg.id
            from descpub_project pr join descpub_project_swgs wg on wg.project_id = pr.id
            join descpub_swg sg on sg.id=wg.swg_id
            where pr.id = ?
            <sql:param value="${projid}"/>
        </sql:query>
        
            <div>
                <h3>Working Groups<h3/>
                <c:forEach var="sRow" items="${swglist.rows}">
                    <a href=show_swg.jsp?swgid=${sRow.id}&name=${sRow.name}>${sRow.name}</a>
                </c:forEach>
            </div>    
           
        <tg:editPublication pubid="${pubid}" projid="${projid}"/>   
        

   
        
    </body>
</html>
