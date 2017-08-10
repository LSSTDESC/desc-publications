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
        
        <h1>Modify Publication</h1>
  <%--
         <sql:update dataSource="jdbc/config-dev"> 
            update descpub_publication set 
                <c:forEach var="x" items="${param}" varStatus="loop">
                    <c:if test ="${!empty x.value && !fn:contains(x.key,'action')}">
                        <c:if test="${!empty x.value && loop.last}">
                            ${x.key} = <sql:param value="${x.value}"/>
                        </c:if>
                        <c:if test="${!empty x.value && !loop.last}">
                            ${x.key} = <sql:param value="${x.value}"/>,
                        </c:if>
                    </c:if>
                </c:forEach> 
            where pubid = ?
            <sql:param value="${param.pubid}"/>
         </sql:update> --%>
        
  
  
  
        <c:forEach var="x" items="${param}" varStatus="loop">
            <c:if test ="${!empty x.value && !fn:contains(x.key,'action')}">
                <c:if test="${!empty x.value && loop.last}">
                    ${x.key}<br/>
                </c:if>
                <c:if test="${!empty x.value && !loop.last}">
                    ${x.key}, <br/>
                </c:if>
            </c:if>
        </c:forEach> 

        
  
  <%--
         <sql:update dataSource="jdbc/config-dev"> 
            update descpub_publication set (
                <c:forEach var="x" items="${param}" varStatus="loop">
                    <c:if test ="${!empty x.value && !fn:contains(x.key,'action')}">
                        <c:if test="${!empty x.value && loop.last}">
                            ${x.key}
                        </c:if>
                        <c:if test="${!empty x.value && !loop.last}">
                            ${x.key},
                        </c:if>
                    </c:if>
                </c:forEach> 
                )
                values (
                <c:forEach var="x" items="${param}" varStatus="loop">
                    <c:if test ="${!empty x.value && !fn:contains(x.key,'action')}">
                        <c:if test="${!empty x.value && loop.last}">
                            ?
                        </c:if>
                        <c:if test="${!empty x.value && !loop.last}">
                            ?,
                        </c:if>
                    </c:if>
                </c:forEach> 
               )  
               <c:forEach var="x" items="${param}" varStatus="loop">
                    <c:if test ="${!empty x.value && !fn:contains(x.key,'action')}">
                        <c:if test="${!empty x.value && loop.last}">
                            <sql:param value = "${x.value}"/>
                        </c:if>
                        <c:if test="${!empty x.value && !loop.last}">
                            <sql:param value = "${x.value}"/>
                        </c:if>
                    </c:if>
                </c:forEach>
            where id = ${param.pubid}
       </sql:update>  --%>
                          
            
        Redirect to show_pub.jsp?pubid=${param.pubid}<br/>
        <%--  <c:redirect url="show_pub.jsp?pubid=${param.pubid}"/>    --%>

       
    </body>
</html>
