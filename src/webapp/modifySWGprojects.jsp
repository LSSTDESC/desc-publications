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
        
    <sql:query var="projects">
        select id,title,summary,state,created,lastmodified,lastmodby,confluenceurl,createdby,gitspaceurl from descpub_project where id = ?
        <sql:param value="${param.projid}"/>
   </sql:query> 
           
   <c:set var="oranames" value="title=?,summary=?,state=?,lastmodby=?,confluenceurl=?,gitspaceurl=?,lastmodified=sysdate"/>
   <c:set var="escSummary" value="${fn:escapeXml(param.summary)}"/>
   <c:set var="confUrl" value="${fn:startsWith(param.confluenceurl,'https://confluence')}"/>
   <c:set var="gitUrl" value="${fn:startsWith(param.gitspaceurl,'https://github')}"/>
   
      
   <c:if test="${! confUrl}">  
       <c:redirect url="noPermission.jsp?errmsg=13"/>  
   </c:if>
   <c:if test="${! gitUrl}">
       <c:redirect url="noPermission.jsp?errmsg=14"/>  
   </c:if>
 <%--  <c:set var="oravals" value="${param.title},${escSummary},${param.state},${userName},${param.confluenceurl},${param.gitspaceurl},sysdate"/> --%>
 
   <c:set var="debugMode" value="false"/>
  

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
                <sql:param value="${param.title}"/>
                <sql:param value="${escSummary}"/>
                <sql:param value="${param.state}"/>
                <sql:param value="${userName}"/>
                <sql:param value="${param.confluenceurl}"/>
                <sql:param value="${param.gitspaceurl}"/>
                <sql:param value="${param.projid}"/>
            </sql:update> 
                           
            <c:if test="${!empty param['srmactivity_id']}">
                <sql:update var="rem">
                    delete from descpub_project_srm_info where srmtype='activity' and project_id = ?
                    <sql:param value="${param.projid}"/>
                </sql:update>
                <c:forEach var="a" items="${paramValues['srmactivity_id']}">
                   <sql:query var="acttitle">
                     select title from descpub_srm_activities where activity_id = ? 
                     <sql:param value="${a}"/>
                   </sql:query>
                   <sql:update var="upd">
                     insert into descpub_project_srm_info (srm_id,srmtitle,srmtype,project_id,entry_date) 
                     values (?,?,?,?,sysdate)
                     <sql:param value="${a}"/>
                     <sql:param value="${acttitle.rows[0]['title']}"/>
                     <sql:param value="activity"/>
                     <sql:param value="${param.projid}"/>
                   </sql:update>   
                </c:forEach>
            </c:if>
            <c:if test="${!empty param['srmdeliverable_id']}">
                <sql:update var="rem2">
                  delete from descpub_project_srm_info where srmtype='deliverable' and project_id = ?
                  <sql:param value="${param.projid}"/>
                </sql:update>
                <c:forEach var="d" items="${paramValues.srmdeliverable_id}">
                    <sql:query var="devtitle">
                      select title from descpub_srm_deliverables where deliverable_id = ?
                      <sql:param value="${d}"/>
                    </sql:query>
                    <sql:update var="upd2">
                        insert into descpub_project_srm_info (srm_id,srmtitle,srmtype,project_id,entry_date) 
                        values (?,?,?,?,sysdate)
                        <sql:param value="${d}"/>
                        <sql:param value="${devtitle.rows[0]['title']}"/>
                        <sql:param value="deliverable"/>
                        <sql:param value="${param.projid}"/>
                     </sql:update>    
                </c:forEach>
            </c:if>
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
