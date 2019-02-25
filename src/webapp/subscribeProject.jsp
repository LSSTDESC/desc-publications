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
        <title>Manage Project Membership for ${param.group_id}</title>
    </head>
    <body>
        
        <c:set var="debugMode" value="false"/>
        
        <c:if test="${debugMode == 'true'}">
            <c:forEach var="p" items="${param}">
                <c:out value="PARAM=${p.key} = ${p.value}"/><br/>
            </c:forEach>
                
            <p></p>
            <c:if test="${param.action == 'leave'}">
               delete from profile_ug where user_id=${param.userid} and group_id=${param.groupname} and experiment=${appVariables.experiment} and memidnum=${param.memidnum})<br/>
            </c:if>          
            <c:if test="${param.action == 'join'}"> 
               insert into profile_ug (user_id, group_id, experiment, memidnum) values(${param.userid}, ${param.groupname}, ${appVariables.experiment},${param.memidnum})<br/>
            </c:if>

        </c:if> 
            
        <sql:query var="membership">
            select memidnum from profile_ug where group_id = ? and memidnum = ?
            <sql:param value="${param.group_id}"/>
            <sql:param value="${param.memidnum}"/>
        </sql:query>
            
        <c:catch var="catchError">    
        <sql:transaction>
        <c:choose>
            <c:when test="${empty membership.rows}">
                <c:if test="${param.grpsubscribe=='join'}">
                    <sql:update>
                       insert into profile_ug (user_id,group_id,experiment,memidnum) values(?,?,?,?)
                       <sql:param value="${param.userName}"/>
                       <sql:param value="${param.group_id}"/>
                       <sql:param value="${appVariables.experiment}"/>
                       <sql:param value="${param.memidnum}"/>
                    </sql:update>
                    <c:out value="You are a member of this project"/>
                </c:if>
                <c:if test="${param.grpsubscribe=='leave'}">
                    <c:out value="You are not a member of this project"/>
                </c:if>
            </c:when> 
            <c:when test="${!empty membership.rows}">
                <c:if test="${param.grpsubscribe=='join'}">
                    <c:out value="You are a member of this project"/>
                </c:if>
                <c:if test="${param.grpsubscribe=='leave'}">
                    <sql:update>
                        delete from profile_ug where group_id = ? and memidnum = ?
                        <sql:param value="${param.group_id}"/>
                        <sql:param value="${param.memidnum}"/>
                    </sql:update>
                    <c:out value="You are not a member of this project"/>
                </c:if>
            </c:when> 
        </c:choose>
        </sql:transaction>  
        </c:catch>
                        
        <c:choose>
        <c:when test="${!empty catchError}">
           <h3>Error: ${catchError}</h3>
        </c:when>
        <c:otherwise>
            ${param.returnURL}
         <%--  <c:redirect url="${param.returnURL}"/> --%>
        </c:otherwise>
        </c:choose>  

    </body>
</html>
