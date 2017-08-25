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
        
        <c:forEach var="x" items="${param}">
            <c:if test="${x.key != 'action' && x.key != 'swgid'}">
                <c:choose>
                <c:when test="${empty oranames}">
                   <c:set var="oranames" value="${x.key}=? "/>
                </c:when>
                <c:when test="${!empty oranames}">
                   <c:set var="oranames" value="${oranames},${x.key}=? "/>
                </c:when>
                </c:choose>
            </c:if>
        </c:forEach> 
   
        <sql:update dataSource="jdbc/config-dev">   
            update descpub_publication set ${oranames} where id = ?  
            <c:forEach var="x" items="${param}">
                <c:if test="${x.key != 'action' && x.key != 'swgid'}">
                <sql:param value="${x.value}"/>
                </c:if>
            </c:forEach>          
            <sql:param value="${param.id}"/>
        </sql:update>   
           
       <c:redirect url="show_pub.jsp?pubid=${param.id}"/>     

    </body>
</html>
