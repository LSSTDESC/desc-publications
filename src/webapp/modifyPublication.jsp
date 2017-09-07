<%-- 
    Document   : modifyPublication
    Created on : Aug 8, 2017, 12:35:15 PM
    Author     : chee
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>



<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modify Publication</title>
    </head>
    <body>
         
        <c:set var="oranames" value=""/>
        <c:set var="orafields" value=""/>

        <c:forEach var="x" items="${param}">
            <c:if test="${x.key == 'project_id'}">
                <c:set var="projid" value="${x.value}"/>
            </c:if>
            <c:if test="${x.key == 'paperid'}">
                <c:set var="paperid" value="${x.value}"/>
            </c:if>
            <c:if test="${x.key == 'swgid'}">
                <c:set var="swgid" value="${x.value}"/>
            </c:if>
            <c:if test="${x.key != 'action' && x.key != 'swgid' && x.key != 'added' && x.key != 'project_id' && x.key != 'paperid'}">
                <c:choose>
                    <c:when test="${empty oranames}">
                       <c:set var="oranames" value="${x.key}=? "/>
                       <c:set var="orafields" value="${x.key}"/>
                    </c:when>
                    <c:when test="${!empty oranames}">
                       <c:set var="oranames" value="${oranames},${x.key}=? "/>
                       <c:set var="orafields" value="${orafields},${x.key}"/>
                    </c:when>
                </c:choose>
            </c:if>
        </c:forEach> 
        
        <c:set var="array" value="${fn:split(orafields,',')}"/><p/>
        
        <sql:update dataSource="jdbc/config-dev">
        update descpub_publication set ${oranames}
        <c:forEach var="ar" items="${array}">
            <c:forEach var="y" items="${param}">
                <c:if test="${ar == y.key}">
                    <sql:param value="${y.value}"/>
                </c:if>
            </c:forEach>
        </c:forEach>         
        where paperid = ? and project_id = ?
        <sql:param value="${paperid}"/>
        <sql:param value="${projid}"/>
        </sql:update>
        <%--
        <sql:update dataSource="jdbc/config-dev"> 
            update descpub_publication set ${oranames} where paperid = ?   
            <c:forEach var="x" items="${param}">
                <c:if test="${x.key != 'action' && x.key != 'swgid'}">
                <sql:param value="${x.value}"/> 
                </c:if>
            </c:forEach>          
         <sql:param value="${param.id}"/>
        </sql:update>  --%>
        
                
   <c:redirect url="show_pub.jsp?paperid=${paperid}&projid=${projid}&swgid=${swgid}"/>    
    </body>
</html>
