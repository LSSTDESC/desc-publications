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
      <%--  <c:set var="projid" value="${param.projid}"/> --%>
        <c:set var="swgid" value="${param.swgid}"/>
        <c:set var="wglist" value=""/>
       
        <sql:query var="info">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
        
        <sql:query var="countpapers">
            select count(*) from descpub_publication where project_id = ?
            <sql:param value="${projid}"/>
        </sql:query>   
       
        <c:set var="projid" value="${info.rows[0].project_id}"/>
        <c:set var="returnURL" value="show_pub.jsp?paperid=${paperid}&swgid=${swgid}"/>
        <c:set var="paperleads" value="paper_leads_${paperid}"/>
        <%-- get working groups associated with this pub 
        <sql:query var="swglist">
            select sg.name, sg.id, sg.convener_group_name cgn from descpub_project pr join descpub_project_swgs wg on wg.project_id = pr.id
            join descpub_swg sg on sg.id=wg.swg_id
            where pr.id = ?
            <sql:param value="${info.rows[0].project_id}"/>
        </sql:query>--%>
        <sql:query var="swglist">
            select wg.id, wg.name from descpub_project_swgs jo join descpub_swg wg on jo.swg_id = wg.id where jo.project_id = ?
            <sql:param value="${info.rows[0].project_id}"/>
        </sql:query>
             
        <tg:editPublication paperid="${paperid}"/> 
         
         <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,paperleads) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
         <p></p>
         <hr align="left" width="50%"/>
         <p></p>
         Add or Remove Lead Authors
         <p></p>
         <tg:groupMemberEditor groupname="${paperleads}" returnURL="${returnURL}"/> 
         <p>
             
         <c:if test="${countpapers.rowCount > 0}">     
            <a href="uploadPub.jsp">upload Document</a> &nbsp;&nbsp;&nbsp;&nbsp;
         </c:if>
         
         </c:if>
         <a href="requestAuthorship.jsp?paperid=${paperid}">Request Authorship</a>
      
    </body>
</html>
