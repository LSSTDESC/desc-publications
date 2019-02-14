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

        <sql:query var="ptype">
            select pubtype from descpub_publication where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query>
        <c:set var="pubtype" value="${ptype.rows[0].pubtype}"/>
        
        <sql:query var="fields">
           select pb.metaid, me.data, me.label, me.datatype, me.numrows, me.numcols, pb.sqlstr, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
           where pb.pubtype = ? order by pb.formposition
           <sql:param value="${pubtype}"/>
        </sql:query>

        <c:set var="oranames" value=""/>
        
        <c:catch var="catchError">
          <sql:transaction>
             <%-- make string of columns for Oracle update for this pubtype --%>
             <c:forEach var="field" items="${fields.rows}">
                 <c:forEach var="p" items="${param}">
                     <c:if test="${field.data == p.key && !empty p.value}">
                         <c:choose>
                             <c:when test="${empty oranames}">
                                 <c:set var="oranames" value="${p.key}=?"/>
                             </c:when>
                             <c:when test="${!empty oranames}">
                                 <c:set var="oranames" value="${oranames},${p.key}=?"/>
                             </c:when>
                         </c:choose>
                     </c:if>
                 </c:forEach>
             </c:forEach>
             <%-- do the update --%>
             <sql:update>
                  update descpub_publication set ${oranames} where paperid = ?
                   <c:forEach var="f" items="${fields.rows}">
                      <c:forEach var="p" items="${param}">
                          <c:if test="${f.data == p.key && !empty p.value}">
                              <c:choose>
                              <c:when test="${f.datatype == 'textarea'}">
                                   <sql:param value="${fn:escapeXml(p.value)}"/> 
                              </c:when>
                              <c:when test="${f.datatype != 'textarea'}">
                                   <sql:param value="${p.value}"/> 
                              </c:when>
                              </c:choose>
                         </c:if>
                      </c:forEach>
                   </c:forEach>
                   <sql:param value="${param.paperid}"/>
              </sql:update>   
              <%-- modify info not part of pubtype so update it here --%>
              <sql:update>  
                   update descpub_publication set modifydate=sysdate, modby=?
                   <sql:param value="${userName}"/>
              </sql:update>
                  
          </sql:transaction>
        </c:catch>  

        <c:choose>
            <c:when test="${!empty catchError}">
               <h3>
                Error=${catchError}<br/>
               <c:set var="arrFields" value="${fn:split(oranames,',')}"/><br/>
               <c:set var="arrVals" value="${fn:split(oravals,',')}"/> <br/>

               <c:forEach var="x" items="${arrFields}" varStatus="loop">
                   <c:out value="col=${arrFields[loop.index]}  value=${arrVals[loop.index]}"/><br/>
               </c:forEach>  
               </h3>  
           </c:when>
           <c:when test="${empty catchError}">
              <c:redirect url="editLink.jsp?paperid=${param.paperid}"/>  
           </c:when>   
       </c:choose>    
        
   </body>
</html>
