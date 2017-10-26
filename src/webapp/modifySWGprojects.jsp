<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>
 
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modify Project ${param.projid}</title>
    </head>
    <body>
      
   <c:set var="updateProj" value=""/>
   <c:set var="oranames" value=""/>
   <c:set var="oravals" value=""/>
   
   <sql:query var="cols">
       select lower(column_name) as colname from user_tab_cols where table_name = ?
       <sql:param value="DESCPUB_PROJECT"/>
   </sql:query>
          
   <c:forEach var="x" items="${cols.rows}" varStatus="loop">
       <c:forEach var="p" items="${param}">
           <c:if test="${fn:contains(x['colname'],p.key) && !empty p.value}">
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
                update descpub_project set ${oranames} 
                <c:forEach var="y" items="${oravals}">
                  <sql:param value="${y}"/>
                </c:forEach>
                where id = ?
                <sql:param value="${param.projid}"/>
            </sql:update>   
        </sql:transaction>
    </c:catch>
      
    <%--    
    <c:catch var="catchError">
        
        <h2>  UPDATE DESCPUB_PROJECT SET ${orafields} VALUES(${param.title},${param.abs}, ${param.chgstate},${param.isKeyprj}, ${param.userName} WHERE ID=${param.projid}</h2>
        
        
        <p/>
       <sql:update>
            update descpub_project set ${orafields} where id = ?
            <sql:param value="${param.title}"/> 
            <sql:param value="${param.abs}"/>
            <sql:param value="${param.chgstate}"/>
            <sql:param value="${param.isKeyprj}"/>
            <sql:param value="${param.userName}"/>
            <sql:param value="${param.projid}"/> 
        </sql:update>
 
        <c:if test="${!empty paramValues.removeprojswg}">
            <c:if test="${fn:length(paramValues.removeprojswg) < swgcount.rows[0].tot}">
               <c:forEach var="pv" items="${paramValues.removeprojswg}">
                   <sql:update>
                       delete from descpub_project_swgs where project_id = ? and swg_id = ?
                       <sql:param value="${param.projid}"/>
                       <sql:param value="${pv}"/>
                   </sql:update> 
               </c:forEach>
               <c:set var="updateProj" value="done"/>      
            </c:if>
            <c:if test="${fn:length(paramValues.removeprojswg) == swgcount.rows[0].tot}"> project must have at least one wg assigned to it  
               <c:redirect url="noPermission.jsp?errmsg=2"/>
            </c:if>
        </c:if>

        <c:if test="${!empty paramValues.addprojswg}">
            <c:forEach var="pv" items="${paramValues.addprojswg}">
                <sql:update>
                    insert into descpub_project_swgs (id,project_id,swg_id) values (descpub_proj_swg_seq.nextval,?,?)
                <sql:param value="${param.projid}"/>
                <sql:param value="${pv}"/>
                </sql:update>   
            </c:forEach>
            <c:set var="updateProj" value="done"/>      
        </c:if>
    </c:catch>  
                
    <c:if test="${catchError != null}">
        UPDATES Failed.
    </c:if> --%>
     
    <c:redirect url="${param.redirectURL}&updateProj=${updateProj}"/>    
    </body>
</html>
