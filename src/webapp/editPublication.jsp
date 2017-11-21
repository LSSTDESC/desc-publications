<%-- 
    Document   : editPublication
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
        <title>Edit Document</title>
    </head>
    <body>
         
        <c:set var="oranames" value=""/>
        <c:set var="oravals" value=""/>
        <c:set var="newTitle" value=""/>
        <c:set var="newSummary" value=""/>

        <sql:query var="cols">
          select lower(column_name) as colname from user_tab_cols where table_name = ?
          <sql:param value="DESCPUB_PUBLICATION"/>
        </sql:query>
        
        <sql:query var="getprj">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query>
        <c:set var="projid" value="${getprj.rows[0].project_id}"/> 
        
        <%-- handle the summary and title separately so we don't have to worry if they contain commas, interferring when building oranames and oravalues --%> 
        
        <c:forEach var="x" items="${cols.rows}" varStatus="loop">
           <c:if test="${!fn:contains(x['colname'],'paperid')}">
           <c:forEach var="p" items="${param}">
               <c:if test="${fn:contains(x['colname'],p.key) && p.key != 'summary' && p.key != 'added' && p.key != 'title' && !empty p.value }">
                  <c:choose>
                       <c:when test="${empty oranames}">
                           <c:set var="oranames" value="${p.key}=? "/>
                           <c:set var="oravals" value="${p.value}"/>
                       </c:when>
                       <c:when test="${!empty oranames}">
                           <c:set var="oranames" value="${oranames},${p.key}=? "/>
                           <c:set var="oravals" value="${oravals},${p.value}"/>
                       </c:when>
                   </c:choose>   
               </c:if>  
               <c:if test="${p.key == 'summary' && !empty p.value && empty newSummary}">
                   <c:set var="newSummary" value="${p.value}"/>
               </c:if>
               <c:if test="${p.key == 'title' && !empty p.value && empty newTitle}">
                   <c:set var="newTitle" value="${p.value}"/>
               </c:if>
           </c:forEach>
           </c:if> 
        </c:forEach>
        
        <%-- tack on modify information  --%>
        <c:set var="oranames" value="${oranames}, date_modified=sysdate, modby=?"/>
        <c:set var="oravals" value="${oravals},${userName}"/>
        
     <c:catch var="catchError"/>
     <sql:transaction>
        <sql:update>
            update descpub_publication set ${oranames} where paperid = ? and project_id = ?
                <c:forEach var="y" items="${oravals}">
                     <sql:param value="${y}"/>
                </c:forEach>
            <sql:param value="${param.paperid}"/>
            <sql:param value="${projid}"/>
        </sql:update> 
            
         <sql:update>
            update descpub_publication set title = ? where paperid = ? and project_id = ?
            <sql:param value="${newTitle}"/>
            <sql:param value="${param.paperid}"/>
            <sql:param value="${projid}"/>
         </sql:update>
            
         <sql:update>
            update descpub_publication set summary = ? where paperid = ? and project_id = ?
            <sql:param value="${newSummary}"/>
            <sql:param value="${param.paperid}"/>
            <sql:param value="${projid}"/>
         </sql:update>
     </sql:transaction> 
     
     <c:choose>
         <c:when test="${!empty catchError}">
             <h3>
             Error=${catchError}
             </h3>  
         </c:when>
         <c:otherwise>
            <c:redirect url="show_pub.jsp?paperid=${paperid}&projid=${projid}&swgid=${swgid}"/>    
        </c:otherwise>
    </c:choose>
            
    </body>
</html>
