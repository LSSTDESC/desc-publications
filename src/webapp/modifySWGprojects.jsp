<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modify Project ${param.projid}</title>
    </head>
    <body>
      
   <c:set var="oranames" value=""/>
   <c:set var="oravals" value=""/>
   <c:set var="debugMode" value="false"/>
   
   <sql:query var="projects">
        select id, title, srmact, summary, state, created, lastmodified, lastmodby from descpub_project where id = ?
        <sql:param value="${param.projid}"/>
   </sql:query> 
          
   <c:if test="${debugMode=='true'}">
       <c:forEach var="x" items="${param}" varStatus="loop">
           <c:if test="${x.key == 'summary'}">
               summary found<br/>
           </c:if>
            <c:forEach var="a" items="${projects.rows}">
                <c:if test="${!empty a[x.key]}">
                  <c:out value="Param: ${x.key} = ${x.value}"/><br/>
                  <c:out value="DB: ${a[x.key]}"/><p/>
                </c:if>
            </c:forEach>
        </c:forEach>
    </c:if>
              
   <%-- get column names and build query string --%>    
   <sql:query var="cols">
       select lower(column_name) as colname from user_tab_cols where table_name = ?
       <sql:param value="DESCPUB_PROJECT"/>
   </sql:query>
          
    <c:forEach var="x" items="${cols.rows}" varStatus="loop">
        <c:forEach var="p" items="${param}">
            <c:if test="${fn:contains(x['colname'],p.key) &&  p.key != 'summary' && p.key != 'title' && !empty p.value}">
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
            <c:if test="${p.key == 'title'}">
                <c:set var="newTitle" value="${p.value}"/>
            </c:if>
            <c:if test="${p.key == 'summary'}">
                <c:set var="newSummary" value="${p.value}"/>
            </c:if>
        </c:forEach>
    </c:forEach>
                
   <%-- tack on modify information --%>
   <c:set var="oranames" value="${oranames},lastmodified=sysdate"/>
   <c:set var="oranames" value="${oranames},lastmodby=?"/>
   <c:set var="oravals" value="${oravals},${userName}"/>
  
   <sql:query var="swgcount">
      select count(*) tot from descpub_project_swgs where project_id = ?
      <sql:param value="${param.projid}"/>
   </sql:query>
      
    <%-- if only one working group remains then delete is not allowed. projects must have at least one wg --%>
    <c:if test="${swgcount.rows[0].tot < 2 && !empty param.removeprojswg}">
       <c:redirect url="noPermission.jsp?errmsg=2"/>
    </c:if>
   
    <c:catch var="catchError">
        <sql:transaction>
            <sql:update>
                update descpub_project set ${oranames} where id = ?
                <c:forEach var="y" items="${oravals}">
                  <sql:param value="${y}"/>
                </c:forEach>
                <sql:param value="${param.projid}"/>
            </sql:update>  
            <sql:update>
                update descpub_project set title = ? where id = ?
                <sql:param value="${newTitle}"/>
                <sql:param value="${param.projid}"/>
            </sql:update>
            <sql:update>
                update descpub_project set summary = ? where id = ?
                <sql:param value="${newSummary}"/>
                <sql:param value="${param.projid}"/>
            </sql:update>
            
            <c:if test="${!empty paramValues.addprojswg}">
              <c:forEach var="pv" items="${paramValues.addprojswg}">
                <sql:update>
                    insert into descpub_project_swgs (id,project_id,swg_id) values (descpub_proj_swg_seq.nextval,?,?)
                <sql:param value="${param.projid}"/>
                <sql:param value="${pv}"/>
                </sql:update>   
              </c:forEach>
            </c:if>
             
            <c:if test="${!empty paramValues.removeprojswg}">
                <c:if test="${fn:length(paramValues.removeprojswg) < swgcount.rows[0].tot}">
                   <c:forEach var="pv" items="${paramValues.removeprojswg}">
                       <sql:update>
                           delete from descpub_project_swgs where project_id = ? and swg_id = ?
                           <sql:param value="${param.projid}"/>
                           <sql:param value="${pv}"/>
                       </sql:update> 
                   </c:forEach>
                </c:if>
                <c:if test="${fn:length(paramValues.removeprojswg) == swgcount.rows[0].tot}"> project must have at least one wg assigned to it  
                   <c:redirect url="noPermission.jsp?errmsg=2"/>  
                </c:if>
            </c:if>  
            
        </sql:transaction>
    </c:catch> 
      
    <c:choose>
        <c:when test="${!empty catchError}">
            <h3>Error: ${catchError}</h3>
        </c:when>
        <c:otherwise>
            
           <c:redirect url="${param.redirectURL}"/>   
        </c:otherwise>
    </c:choose>
    
    
    </body>
</html>
