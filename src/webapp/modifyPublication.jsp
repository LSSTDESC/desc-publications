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
            <c:out value="KEY: ${x.key} =${x.value}"/><br/>
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
                        <c:if test="${! empty x.value}">
                           <c:set var="oranames" value="${x.key}=? "/>
                           <c:set var="orafields" value="${x.value}"/>
                        </c:if>
                    </c:when>
                    <c:when test="${!empty oranames}">
                        <c:if test="${! empty x.value}">
                           <c:set var="oranames" value="${oranames},${x.key}=? "/>
                           <c:set var="orafields" value="${orafields},${x.value}"/>
                        </c:if>
                    </c:when>
                </c:choose>
            </c:if>
        </c:forEach> 
     
        
        <sql:update>
            update descpub_publication set ${oranames} 
                <c:forEach var="y" items="${orafields}">
                     <sql:param value="${y}"/>
                </c:forEach>
                where paperid = ? and project_id = ?
            <sql:param value="${paperid}"/>
            <sql:param value="${projid}"/>
        </sql:update>   
            
  <c:redirect url="show_pub.jsp?paperid=${paperid}&projid=${projid}&swgid=${swgid}"/>    
    </body>
</html>
