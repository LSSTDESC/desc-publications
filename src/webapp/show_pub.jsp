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
        
        <tg:underConstruction/>

        <c:set var="paperid" value="${param.paperid}"/>
        <c:set var="projid" value="${param.projid}"/>
        <c:set var="swgid" value="${param.swgid}"/>
        <c:set var="returnURL" value="show_pub.jsp?paperid=${paperid}&projid=${projid}&swgid=${swgid}"/>
        
        <sql:query var="info">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
        
        <%-- get working groups associated with this pub --%>
        <sql:query var="swglist">
            select sg.name, sg.id, sg.convener_group_name from descpub_project pr join descpub_project_swgs wg on wg.project_id = pr.id
            join descpub_swg sg on sg.id=wg.swg_id
            where pr.id = ?
            <sql:param value="${info.rows[0].project_id}"/>
        </sql:query>
        
        <div>
            <h3>Working Groups</h3>
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
         
         <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'AnalysisCoordinator') || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
         <p></p>
         <hr align="left" width="50%"/>
         <p></p>
         Add or Remove Authors
         <p></p>
         <tg:groupMemberEditor groupname="paper_${paperid}" returnURL="${returnURL}"/> 
         <p></p>
         <a href="uploadPub.jsp">upload Document</a> &nbsp;&nbsp;&nbsp;&nbsp;
         
         </c:if>
         <a href="requestAuthorship.jsp?paperid=${paperid}">Request Authorship</a>
      
    </body>
</html>
