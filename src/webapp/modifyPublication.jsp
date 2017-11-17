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
        <c:set var="oravals" value=""/>
        
        <sql:query var="cols">
          select lower(column_name) as colname from user_tab_cols where table_name = ?
          <sql:param value="DESCPUB_PUBLICATION"/>
        </sql:query>
        
        <sql:query var="getprj">
            select project_id from descpub_project_papers where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query>
        <c:set var="projid" value="${getprj.rows[0].project_id}"/>  
        
        <c:forEach var="x" items="${cols.rows}" varStatus="loop">
+           <c:forEach var="p" items="${param}">
+               <c:if test="${fn:contains(x['colname'],p.key) && p.key != 'summary' && p.key != 'added' && p.key != 'title' && !empty p.value }">
+               <%--  <c:out value="${x['colname']} = ${p.key} val = ${p.value}"/><br/> --%> 
+                   <c:choose>
+                       <c:when test="${empty oranames}">
+                           <c:set var="oranames" value="${p.key}=? "/>
+                           <c:set var="oravals" value="${p.value}"/>
+                       </c:when>
+                       <c:when test="${!empty oranames}">
+                           <c:set var="oranames" value="${oranames},${p.key}=? "/>
+                           <c:set var="oravals" value="${oravals},${p.value}"/>
+                       </c:when>
+                   </c:choose>  
+               </c:if>  
+               
+               <%-- handle the summary and title separately so we don't have to worry if they contain commas interferring when building oranames and oravalues --%> 
+               <c:if test="${p.key == 'summary' && !empty p.value}">
+                   <c:set var="newSummary" value="${p.value}"/>
+               </c:if>
+               <c:if test="${p.key == 'title' && !empty p.value}">
+                   <c:set var="newTitle" value="${p.value}"/>
+               </c:if>
+           </c:forEach>
+        </c:forEach>
+        
+        <%-- tack on modify information  --%>
+        <c:set var="oranames" value="${oranames}, date_modified=sysdate"/>
+        <c:set var="oranames" value="${oranames},modby=?"/>
+        <c:set var="oravals" value="${oravals},${userName}"/>

         update descpub_publication set ${oranames} where paperid = ${param.paperid} and project_id = ${projid}<br/>
         <c:forEach var="y" items="${oravals}">
            <c:out value="${y}"/><br/>
         </c:forEach>
         
         <c:if test="${!empty newSummary}">
            update descpub_publication set summary = ${newSummary} where paperid = ${param.paperid} and project_id = ${projid}
         </c:if>
         <c:if test="${!empty newTitle}">
            update descpub_publication set title = ${newTitle} where paperid = ${param.paperid} and project_id = ${projid}
         </c:if>
      <%-- 
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
                           <c:set var="oravals" value="${x.value}"/>
                        </c:if>
                    </c:when>
                    <c:when test="${!empty oranames}">
                        <c:if test="${! empty x.value}">
                           <c:set var="oranames" value="${oranames},${x.key}=? "/>
                           <c:set var="oravals" value="${oravals},${x.value}"/>
                        </c:if>
                    </c:when>
                </c:choose>
            </c:if>
        </c:forEach> 
     
        
        <sql:update>
            update descpub_publication set ${oranames} 
                <c:forEach var="y" items="${oravals}">
                     <sql:param value="${y}"/>
                </c:forEach>
                where paperid = ? and project_id = ?
            <sql:param value="${paperid}"/>
            <sql:param value="${projid}"/>
        </sql:update>   
            --%>
  <c:redirect url="show_pub.jsp?paperid=${paperid}&projid=${projid}&swgid=${swgid}"/>    
    </body>
</html>
