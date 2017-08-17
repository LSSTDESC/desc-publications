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
   
   <%-- <c:if test="${!(gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'descpubConvenerAdmin'))}">  
    <c:if test="${!(gm:isUserInGroup(pageContext,'GroupManagerAdmin'))}">
        <c:redirect url="noPermission.jsp?errmsg=1"/>
    </c:if> --%>
      
   <c:set var="update" value=""/>
   
    <sql:query var="swgcount" dataSource="jdbc/config-dev">
       select count(*) tot from descpub_project_swgs where project_id = ?
       <sql:param value="${param.projid}"/>
    </sql:query>
    
    <%-- if only one working group remains then delete is not allowed. projects must have at least one wg --%>
    <c:if test="${swgcount.rows[0].tot < 2 && !empty param.removeprojswg}">
       <c:redirect url="noPermission.jsp?errmsg=2"/>
    </c:if>
   
   
    <c:forEach var="row" items="${param}">
        <c:out value="${row.key} = ${row.value}"/><br/>
            <sql:update dataSource="jdbc/config-dev">
                update descpub_project set title= ?, abstract = ?, state = ?, comments = ?, keyprj = ?, lastmodified = sysdate
                where id = ?
                <sql:param value="${param.title}"/> 
                <sql:param value="${param.abs}"/>
                <sql:param value="${param.chgstate}"/>
                <sql:param value="${param.comm}"/> 
                <sql:param value="${empty isKeyProj ? 'N':'Y'}"/>
                <sql:param value="${param.projid}"/> 
            </sql:update>
            <c:set var="update" value="done"/>      
    </c:forEach>
    
    <c:if test="${!empty paramValues.removeprojswg}">
        <c:if test="${fn:length(paramValues.removeprojswg) < swgcount.rows[0].tot}">
           <c:forEach var="pv" items="${paramValues.removeprojswg}">
                <sql:update dataSource="jdbc/config-dev">
                   delete from descpub_project_swgs where project_id = ? and swg_id = ?
                   <sql:param value="${param.projid}"/>
                   <sql:param value="${pv}"/>
               </sql:update> 
           </c:forEach>
           <c:set var="update" value="done"/>      
        </c:if>
        <c:if test="${fn:length(paramValues.removeprojswg) == swgcount.rows[0].tot}"> <%-- project must have at least one wg assigned to it --%>
           <c:redirect url="noPermission.jsp?errmsg=2"/>
        </c:if>

    </c:if>
                 
    <c:if test="${!empty paramValues.addprojswg}">
        <c:forEach var="pv" items="${paramValues.addprojswg}">
            <sql:update dataSource="jdbc/config-dev">
                insert into descpub_project_swgs (id,project_id,swg_id) values (descpub_proj_swg_seq.nextval,?,?)
            <sql:param value="${param.projid}"/>
            <sql:param value="${pv}"/>
            </sql:update>   
        </c:forEach>
        <c:set var="update" value="done"/>      
    </c:if>
        
    <c:redirect url="${param.redirectURL}?projid=${param.projid}&swgid=${param.swgid}&name=${param.title}&update=${update}"/>  

    </body>
</html>
