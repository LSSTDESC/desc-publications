<%-- 
    Document   : editPublication
    Created on : Aug 8, 2017, 12:35:15 PM
    Author     : chee
--%>

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>


<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Edit Document</title>
    </head>
    <body>
     
    <%-- handle the summary and title separately so we don't have to worry if they contain commas, interferring when building oranames and oravalues --%> 

    <c:set var="oranames" value="modifydate=sysdate,modby=?"/>
    <c:set var="oravals" value="${userName}"/>

    <c:forEach var="p" items="${param}">
        <c:if test="${p.key != 'submit'}">
            <c:out value="${p.key} = ${p.value}"/><br/>
            <c:set var="oranames" value="${oranames},${p.key}=?"/>
            <c:set var="oravals" value="${oravals},${p.value}"/>
        </c:if>
    </c:forEach>

    <c:catch var="catchError">
      <sql:transaction>
         <sql:update>
          update descpub_publication set ${oranames} where paperid = ?
           <c:forEach var="o" items="${oravals}">
             <sql:param value="${o}"/>
           </c:forEach>
           <sql:param value="${param.paperid}"/>
          </sql:update>   
      </sql:transaction>
    </c:catch>

    <c:choose>
        <c:when test="${!empty catchError}">
           <h3>
            Error=${catchError}<br/>

           <c:set var="arrFields" value="${fn:split(oranames,',')}"/>
           <c:set var="arrVals" value="${fn:split(oravals,',')}"/> 

           <c:forEach var="x" items="${arrFields}" varStatus="loop">
               <c:out value="field=${arrFields[loop.index]}  value=${arrVals[loop.index]}"/><br/>
           </c:forEach>  
           </h3>  
       </c:when>
       <c:when test="${empty catchError}">
           update successful
      <%--   <c:redirect url="editLink.jsp?paperid=${param.paperid}&swgid=${param.swgid}"/> --%>
      <c:redirect url="editLink.jsp?paperid=${param.paperid}"/>  
       </c:when>   
   </c:choose>
     
                 
    </body>
</html>
