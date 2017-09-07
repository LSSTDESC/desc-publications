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
        
        <c:set var="paperid" value="${param.paperid}"/>
        
        <sql:query var="info" dataSource="jdbc/config-dev">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
        
        <%-- get working groups associated with this pub --%>
        <sql:query var="swglist" dataSource="jdbc/config-dev">
            select sg.name, sg.id
            from descpub_project pr join descpub_project_swgs wg on wg.project_id = pr.id
            join descpub_swg sg on sg.id=wg.swg_id
            where pr.id = ?
            <sql:param value="${info.rows[0].project_id}"/>
        </sql:query>
        
            
        <div>
            <h3>Working Groups<h3/>
            <c:forEach var="sRow" items="${swglist.rows}" varStatus="loop">
                <c:if test="${!loop.last}">
                <a href="show_swg.jsp?swgid=${sRow.id}&swgname=${sRow.name}">${sRow.name}, </a>
                </c:if>
                <c:if test="${loop.last}">
                <a href="show_swg.jsp?swgid=${sRow.id}&swgname=${sRow.name}">${sRow.name}</a>
                </c:if>
            </c:forEach>
        </div>    
           
         <tg:editPublication paperid="${paperid}"/> 

    </body>
</html>
